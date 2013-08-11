class StringFlightFilter < FlightFilter
  def initialize(parent, filter_string)
    @parent, @filter_string = [parent, filter_string]
  end

  def flights
    if @filter_string && !@filter_string.blank?
      @parent.flights.select do |flight|
        @filter_string.split(',').map(&:strip).map do |filter|
          method, value = filter.split(':').map(&:strip)
          flight.send(method.to_sym).to_s =~ /#{value}/
        end.reduce(&:"&&")
      end
    else
      @parent.flights
    end
  end
end
