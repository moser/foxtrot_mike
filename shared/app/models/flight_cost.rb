#TODO rename? TimeCost (<=> EngineTimeCost)

class FlightCost
  attr_reader :flight
  
  def initialize(flight)
    @flight = flight
  end
  
  def sum
    (costs.map { |e| e.value }).sum
  end

  def value
    (time_costs.map { |e| e.value }).sum
  end

  def costs
    [ launch_cost, time_costs ].flatten.select { |e| !e.nil? }
  end
  
  def launch_cost
    @flight.launch.nil? ? nil : @flight.launch.cost #if there is no launch => selflaunched
  end

  def time_costs
    [ TimeCost.new(@flight, :duration), TimeCost.new(@flight, :engine_duration) ]
  end
end
