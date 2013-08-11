class StringFlightFilter < FlightFilter
  def initialize(parent, filter_string)
    @parent, @filter_string = [parent, filter_string]
  end

  def flights
    if @filter_string && !@filter_string.blank?
      @parent.flights.select { |flight| matches?(flight) }
    else
      @parent.flights
    end
  end

private
  def matches?(flight)
   filters.map do |filter|
      flight.send(filter[:method]).to_s =~ /#{filter[:value]}/
    end.reduce(&:"&&")
  end

  def filters
    @filter_string.split(',').map(&:strip).map do |str|
      method, value = str.split(':').map(&:strip)
      { method: method.to_sym, value: value }
    end
  end
end
