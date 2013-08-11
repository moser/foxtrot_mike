class AffiliationFlightFilter < FlightFilter
  def initialize(parent, model_class, id)
    @parent, @model_class, @id = [parent, model_class, id]
  end

  def flights
    if @model_class && @id
      filter_by = @model_class.singularize.camelcase
      raise ActiveRecord::RecordNotFound.new unless %w(Airfield License Group Plane Person).include?(filter_by)
      filter_by.constantize.find(@id).flights
    else
      parent_flights
    end
  end
end
