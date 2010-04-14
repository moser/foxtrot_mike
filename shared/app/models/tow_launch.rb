class TowLaunch < Launch
  belongs_to :tow_flight, :dependent => :destroy, :autosave => true
  
  def cost
    #if ...
    tow_flight.cost
  end
  
  def available_tow_cost_rules
    unless flight.cost_responsible.nil?
      person_cost_categories = flight.cost_responsible.person_cost_category_memberships.find_all { |m| m.valid_at?(flight.departure) }.map { |m| m.person_cost_category }
      tow_flight.plane.plane_cost_category_memberships.find_all { |m| m.valid_at?(flight.departure) && m.plane_cost_category.tow_cost_rule_type == "TowCostRule" }.map { |m| m.plane_cost_category.tow_cost_rules }.flatten.find_all { |r| r.valid_at?(flight.departure) && person_cost_categories.include?(r.person_cost_category) }  
    else
      []
    end
  end
  
  def available_tow_levels
    available_tow_cost_rules.map { |r| r.tow_levels }.flatten
  end

protected
  def after_initialize
    if new_record?
      self.tow_flight = tow_flight || TowFlight.create(:plane => Defaults.instance.tow_plane)
    end 
  end
end
