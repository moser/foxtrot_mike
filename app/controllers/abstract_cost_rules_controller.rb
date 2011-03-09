class AbstractCostRulesController < ApplicationController
  #before_filter :login_required
  javascript :timepicker

  def self.other_cost_category(sym = nil)
    @other_cost_category = sym unless sym.nil?
    @other_cost_category
  end

  def other_cost_category
    self.class.other_cost_category
  end

  def other_cost_category_class
    other_cost_category.to_s.camelize.constantize  
  end
  
  def index
    if params[:person_cost_category_id] && params["#{other_cost_category}_id"]
      model_all(:person_cost_category_id => params[:person_cost_category_id],
                "#{other_cost_category}_id" => params["#{other_cost_category}_id"])
    else
      model_all_or_after
    end
    @person_cost_category_id = params[:person_cost_category_id]
    eval "@#{other_cost_category}_id = params[:#{other_cost_category}_id]"

    @not_valid_anymore = @models.find_all { |r| r.not_valid_anymore_at?(now) }.sort_by { |r| r.valid_to }
    @valid = @models.find_all { |r| r.valid_at?(now) }.sort_by { |r| r.valid_to || 1000.years.from_now }
    @not_yet_valid = @models.find_all { |r| r.not_yet_valid_at?(now) }.sort_by { |r| r.valid_from }
    respond_to do |format|
      format.html do
        if request.xhr?
          render :layout => false
        end
      end
      format.json  { render :json => @models.to_json }
    end
  end

  def show
    model_by_id
    #render :partial => "#{model_name.underscore.pluralize}/#{model_name.underscore}", :locals => { :rule => @model }
    render :layout => !request.xhr?
  end

  def new
    model_new
    @model.person_cost_category = PersonCostCategory.find(params[:person_cost_category_id]) if params[:person_cost_category_id]
    @model.send("#{other_cost_category}=", other_cost_category_class.find(params["#{other_cost_category}_id"])) if params["#{other_cost_category}_id"]
    respond_to do |format|
      format.html do
        render :layout => !request.xhr?
      end
    end
  end

  def create
    model_new
    respond_to do |format|
      if @model.save
        format.html { redirect_to(polymorphic_path(@model)) }
      else
        format.html { render :action => "new", :layout => !request.xhr?, :status => 422 }
      end
    end
  end

  def update
    model_by_id
    if @model.update_attributes(params[model_name.underscore])
      redirect_to(polymorphic_path(@model))
    else
      render :action => :edit
    end
  end

  def edit
    model_by_id
    if @model.not_valid_anymore_at?(now)
      render :partial => "#{model_name.underscore.pluralize}/#{model_name.underscore}", :locals => { :rule => @model }, :layout => !request.xhr?
    elsif @model.valid_at?(now)
      render :template => "#{model_name.underscore.pluralize}/edit_only_valid_to", :layout => !request.xhr?
    else
      render :layout => !request.xhr?
    end
  end
  
  def destroy
    model_by_id
    authorize! :destroy, @model
    @model.destroy
    respond_to do |format|
      format.html do 
        unless request.xhr?
          if @model.is_a?(FlightCostRule)
            redirect_to(flight_cost_rules_path(:person_cost_category_id => @model.person_cost_category_id, :plane_cost_category_id => @model.plane_cost_category_id)) 
          else
            redirect_to(wire_launch_cost_rules_path(:person_cost_category_id => @model.person_cost_category_id, :wire_launcher_cost_category_id => @model.wire_launcher_cost_category_id)) 
          end
        else
          render :text => "ok"
        end
      end
      format.json { head :ok }
    end
  end

private
  def now
    AccountingSession.latest_session_end
  end
end
