class WireLaunch < Launch
  belongs_to :wire_launcher
  
  def cost
    candidate_costs = flight.cost_responsible.person_cost_category_memberships.map do |m|
      m.person_cost_category.wire_launch_cost_rules.map do |r|
        if r.wire_launcher_cost_category == wire_launcher.wire_launcher_cost_category
          r.cost
        end
      end
    end
    #p candidate_costs
    candidate_costs.flatten.compact.min || 0
  end
end
