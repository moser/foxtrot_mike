class FlightFilter
private
  def parent_flights
    if @parent.is_a?(FlightFilter)
      @parent.flights
    else # ActiveRecord::Relation or so
      @parent
    end
  end
end
