class TimeCost
  attr_reader :flight, :attribute
  
  def initialize(flight, attribute)
    @flight = flight
    @attribute = attribute.to_s
  end
  
  def time
    @flight.departure
  end
  
  def value
    cc = candidate_costs
    min = cc.values.min
    c = cc.find { |k, v| v == min }
    !c.nil? ? c[1] : 0
  end
  
  def cost_rule
    cc = candidate_costs
    min = cc.values.min
    c = cc.find { |k, v| v == min }
    !c.nil? ? c[0] : nil
  end
  
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
        plane_categories.map { |c| c.time_cost_rules }.flatten).find_all { |r| r.valid_at?(time) && r.flight_type == @flight.class.to_s && r.depends_on == @attribute }
    else
      []
    end
  end
end
