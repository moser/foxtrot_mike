class RangeFlightFilter < FlightFilter
  def initialize(parent, range)
    @parent = parent
    @from, @to = range.split("_").map { |s| Date.parse(s) }.sort if range
  end

  def flights
    if @from && @to
      parent_flights.where("departure_date <= ? AND departure_date >= ?", @to, @from)
    else
      parent_flights.limit(40)
    end
  end
end
