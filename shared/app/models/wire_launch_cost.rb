class WireLaunchCost
  def initialize(launch)
    @launch = launch
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
  
  def time
    @launch.abstract_flight.departure
  end
  
  def candidate_rules
    unless @launch.abstract_flight.cost_responsible.nil? || @launch.wire_launcher.nil?
      person_categories = @launch.abstract_flight.cost_responsible.person_cost_category_memberships.find_all { |m| m.valid_at?(time) }.map { |m| m.person_cost_category }
      wire_launcher_categories = @launch.wire_launcher.wire_launcher_cost_category_memberships.find_all { |m| m.valid_at?(time) }.map { |m| m.wire_launcher_cost_category }
      (person_categories.map { |c| c.wire_launch_cost_rules }.flatten & 
        wire_launcher_categories.map { |c| c.wire_launch_cost_rules }.flatten).find_all { |r| r.valid_at?(time) }
    else
      []
    end
  end

  def candidate_costs
    cc = {}
    candidate_rules.each do |r|
      cc[r] = r.cost.to_i #make sure it's an integer, not nil
    end
    cc
  end
end
