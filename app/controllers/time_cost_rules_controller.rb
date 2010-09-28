class TimeCostRulesController < ApplicationController
  #before_filter :login_required
  javascript :timepicker

  def index
    conditions = []
    unless @after.nil?
      conditions = ['updated_at > ?', @after]
    end
    if params[:person_cost_category_id] && params[:plane_cost_category_id]
      conditions = { :person_cost_category_id => params[:person_cost_category_id],
                     :plane_cost_category_id => params[:plane_cost_category_id] }
    end
    @person_cost_category_id = params[:person_cost_category_id]
    @plane_cost_category_id = params[:plane_cost_category_id]

    @time_cost_rules = TimeCostRule.find(:all, :conditions => conditions)
    @not_valid_anymore = @time_cost_rules.find_all { |r| r.not_valid_anymore_at?(now) }.sort_by { |r| r.valid_to }
    @valid = @time_cost_rules.find_all { |r| r.valid_at?(now) }.sort_by { |r| r.valid_to || 1000.years.from_now }
    @not_yet_valid = @time_cost_rules.find_all { |r| r.not_yet_valid_at?(now) }.sort_by { |r| r.valid_from }
    respond_to do |format|
      format.html do
        if request.xhr?
          render :layout => false
        end
      end
      format.json  { render :json => @time_cost_rules.to_json }
    end
  end

  def show
    model_by_id
    render :partial => "time_cost_rules/time_cost_rule", :locals => { :rule => @time_cost_rule }
  end

  def new
    @time_cost_rule = TimeCostRule.new
    @time_cost_rule.person_cost_category = PersonCostCategory.find(params[:person_cost_category_id]) if params[:person_cost_category_id]
    @time_cost_rule.plane_cost_category = PlaneCostCategory.find(params[:plane_cost_category_id]) if params[:plane_cost_category_id]
    respond_to do |format|
      format.html do
        if request.xhr?
          render :layout => false
        end
      end
    end
  end

  def create
    @time_cost_rule = TimeCostRule.new(params[:time_cost_rule])
    respond_to do |format|
      if @time_cost_rule.save
        format.html { redirect_to(time_cost_rule_path(@time_cost_rule)) }
      else
        format.html { render :action => "new", :layout => !request.xhr?, :status => 422 }
      end
    end
  end

  def update
    model_by_id
    if @time_cost_rule.update_attributes(params[:time_cost_rule])
      redirect_to(polymorphic_path(@time_cost_rule))
    else
      render :action => :edit
    end
  end

  def edit
    model_by_id
    if @time_cost_rule.not_valid_anymore_at?(now)
      render :partial => "time_cost_rules/time_cost_rule", :locals => { :rule => @time_cost_rule }
    elsif @time_cost_rule.valid_at?(now)
      render :template => "time_cost_rules/edit_only_valid_to"
    end
  end

private
  def now
    Time.zone.now #TODO booking now
  end
end
