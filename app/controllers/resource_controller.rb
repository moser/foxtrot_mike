class ResourceController < ApplicationController
  def self.nested(parent = nil)
    @parent ||= parent
  end

  def nested
    self.class.nested
  end

  def nested_id
    params[:"#{nested}_id"]
  end

  def find_nested
    @nested = instance_values[nested.to_s] = nested.to_s.camelize.constantize.find(nested_id)
  end

  def self.redirect_to_index(x = false)
    @redirect_to_index ||= x
  end

  def redirect_to_index
    self.class.redirect_to_index
  end

  def index
    model_all_or_after
    authorize! :read, model_class
    if nested && nested_id
      find_nested
      @models = @nested.send(model_name.pluralize.underscore)
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
    authorize! :read, model_class
    render :layout => !request.xhr?
  end

  def new
    model_new
    authorize! :create, @model
    if nested && nested_id
      @model.send(:"#{nested}=", find_nested)
    end
    
    render :layout => !request.xhr?
  end

  def edit
    model_by_id
    authorize! :update, @model
    render :layout => !request.xhr?
  end

  def create
    model_new
    authorize! :create, @model
    if nested && nested_id
      @model.send(:"#{nested}=", find_nested)
    end
    @model.id = params[model_name.underscore.to_sym][:id] unless params[model_name.underscore.to_sym].nil? || params[model_name.underscore.to_sym][:id].nil?
    if @model.save
      respond_to do |f|
        f.html { redirect_to_index ? redirect_to(polymorphic_path(model_class)) : redirect_to(polymorphic_path(@model)) }
        f.json { render :text => "OK"}
      end
    else
      respond_to do |f|
        f.html { render :action => :new, :layout => !request.xhr?, :status => 422 }
        f.json { render :text => "FAIL"}
      end
    end
  end

  def update
    model_by_id
    authorize! :update, @model
    if @model.update_attributes(params[model_name.underscore.to_sym])
      redirect_to_index ? redirect_to(polymorphic_path(model_class)) : redirect_to(polymorphic_path(@model))
    else
      render :action => :edit, :layout => !request.xhr?, :status => 422
    end
  end
  
  def destroy
    model_by_id
    authorize! :destroy, @model
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
