class FinancialAccountOwnershipsController < ResourceController  
  def nested
    unless @nested_class
      if params[:person_id]
        @nested_class = :person
      elsif params[:plane_id]
        @nested_class = :plane
      elsif params[:wire_launcher_id]
        @nested_class = :wire_launcher
      end
    end
    @nested_class
  end
  
  def find_nested
    @nested = instance_values[nested.to_s] = nested.to_s.camelize.constantize.find(nested_id)
  end
end
