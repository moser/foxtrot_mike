class JsonEnabledOnlyController < ResourceController
  def render_index
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.json  do
        if model_class.attribute_names.include?("disabled")
          @models = @models.find_all { |m| !m.disabled? }
        end
        if model_class.instance_method_names.include?("to_j")
          render :json => @models.map { |e| e.to_j }
        elsif model_class.respond_to?(:shared_attribute_names)
          render :json => @models.to_json(:only => model_class.shared_attribute_names)
        else
          render :json => @models.to_json
        end
      end
    end
  end
end
