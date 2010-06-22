#TODO rename? TimeCost (<=> EngineTimeCost)

class FlightCost
  attr_reader :flight
  
  def initialize(flight)
    @flight = flight
  end
  
  def time
    @flight.departure
  end
  
  def to_i #rename: combined value (?)
    launch_cost.to_i + cost_i
  end
  
  def cost_i #rename: value
    c = cost
    !c.nil? ? c[1] : 0
  end
  
  def cost_rule
    c = cost
    !c.nil? ? c[0] : nil
  end
  
  def cost #rename?
    cc = candidate_costs
    cc.find { |k, v| v == cc.values.min }
  end
  
  #TODO engine_time cost
  #     fixed cost tow cost rules
  def candidate_costs
    cc = {}
    candidate_rules.each do |r|
      if r.flight_type = @flight.class.name
        cc[r] = r.cost_for(@flight)
      end
    end
    cc
  end
  
  def candidate_rules
    unless @flight.cost_responsible.nil? || @flight.plane.nil?
      person_categories = @flight.cost_responsible.person_cost_category_memberships.find_all { |m| m.valid_at?(time) }.map { |m| m.person_cost_category }
      plane_categories = @flight.plane.plane_cost_category_memberships.find_all { |m| m.valid_at?(time) }.map { |m| m.plane_cost_category }
      (person_categories.map { |c| c.time_cost_rules }.flatten & 
        plane_categories.map { |c| c.time_cost_rules }.flatten).find_all { |r| r.valid_at?(time) }
    else
      []
    end
  end
  
  def launch_cost
    @flight.launch.nil? ? nil : @flight.launch.cost #if there is no launch => selflaunched
  end
end
