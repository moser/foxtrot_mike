class ResourceController < ApplicationController
  def self.nested(parent = nil)
    @parent ||= parent
  end

  def nested
    self.class.nested
  end

  def self.redirect_to_index(x = false)
    @redirect_to_index ||= x
  end

  def redirect_to_index
    self.class.redirect_to_index
  end

  def index
    model_all_or_after
    if nested && params[:"#{nested}_id"]
      @models = @models.where(:"#{nested}_id" => params[:"#{nested}_id"])
      @nested = instance_values[nested.to_s] = nested.to_s.camelize.constantize.find(params[:"#{nested}_id"])
      #eval '@#{nested} = @nested'
    end
    render_index
  end

  def render_index
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.json  do 
        if model_class.respond_to?(:shared_attribute_names)
          render :json => @models.to_json(:only => model_class.shared_attribute_names)
        else
          render :json => @models.to_json
        end
      end
    end
  end

  def show
    model_by_id
    render :layout => !request.xhr?
  end

  def new
    model_new
    if nested && params[:"#{nested}_id"]
      @model.send(:"#{nested}=", nested.to_s.camelize.constantize.find(params[:"#{nested}_id"]))
    end
    
    render :layout => !request.xhr?
  end

  def edit
    model_by_id

    render :layout => !request.xhr?
  end

  def create
    model_new
    if nested && params[:"#{nested}_id"]
      @model.send(:"#{nested}=", nested.to_s.camelize.constantize.find(params[:"#{nested}_id"]))
    end
    @model.id = params[model_name.underscore.to_sym][:id] unless params[model_name.underscore.to_sym].nil? || params[model_name.underscore.to_sym][:id].nil?
    if @model.save
      redirect_to_index ? redirect_to(polymorphic_path(model_class)) : redirect_to(polymorphic_path(@model))
    else
      p @model.errors
      render :action => :new, :layout => !request.xhr?, :status => 422
    end
  end

  def update
    model_by_id
    if @model.update_attributes(params[model_name.underscore.to_sym])
      redirect_to_index ? redirect_to(polymorphic_path(model_class)) : redirect_to(polymorphic_path(@model))
    else
      render :action => :edit, :layout => !request.xhr?, :status => 422
    end
  end
  
  def destroy
    model_by_id
    if destroy_check
      @model.destroy
    end

    respond_to do |format|
      format.html { redirect_to(polymorphic_path(model_class)) }
      format.json { head :ok }
    end
  end  

  def destroy_check
    true
  end
end
