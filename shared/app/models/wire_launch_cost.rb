class WireLaunchCost
  def initialize(launch)
    @launch = launch
  end
  
  def to_i
    cost[1] #rescue 0
  end
  
  def cost
    candidate_costs.find { |k, v| v == candidate_costs.values.min }
  end
  
  def time
    @launch.flight.departure
  end

  def candidate_costs
    unless @cc
      @cc = {}
      person_categories = @launch.flight.cost_responsible.person_cost_category_memberships.find_all { |m| m.valid_at?(time) }.map { |m| m.person_cost_category }
      wire_launcher_categories = @launch.wire_launcher.wire_launcher_cost_category_memberships.find_all { |m| m.valid_at?(time) }.map { |m| m.wire_launcher_cost_category }
      candidate_rules = person_categories.map { |c| c.wire_launch_cost_rules }.flatten & 
                        wire_launcher_categories.map { |c| c.wire_launch_cost_rules }.flatten
      candidate_rules.each do |r|
        if r.valid_at?(time)
          @cc[r] = r.cost
        end
      end
    end
    @cc
  end
end
