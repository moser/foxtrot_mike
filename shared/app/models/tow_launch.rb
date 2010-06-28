class TowLaunch < Launch
  belongs_to :tow_flight, :dependent => :destroy, :autosave => true
  
  include TowLaunchAddition
  
  def cost
    #if ...
    tow_flight.cost
  end
  
  def available_tow_cost_rules
    unless abstract_flight.cost_responsible.nil?
      person_cost_categories = abstract_flight.cost_responsible.person_cost_category_memberships.find_all { |m| m.valid_at?(abstract_flight.departure) }.map { |m| m.person_cost_category }
      memberships = tow_flight.plane.plane_cost_category_memberships.find_all { |m| m.valid_at?(abstract_flight.departure) && m.plane_cost_category.tow_cost_rule_type == "TowCostRule" }
      memberships.map { |m| m.plane_cost_category.tow_cost_rules }.flatten.find_all { |r| r.valid_at?(abstract_flight.departure) && person_cost_categories.include?(r.person_cost_category) }  
    else
      []
    end
  end
  
  def available_tow_levels
    available_tow_cost_rules.map { |r| r.tow_levels }.flatten
  end
  
  def tow_flight_attributes=(attrs)
    unless attrs.nil?
      obj = attrs.delete(:type).constantize.new(attrs)
      obj.id = attrs[:id]
      obj.save
    end
  end
  
  def shared_attributes
    attrs = attributes
    attrs[:tow_flight_attributes] = tow_flight.shared_attributes
    attrs
  end
  
  def initialize(*args)
    super(*args)
    if new_record?
      self.tow_flight ||= TowFlight.create(:plane => Defaults.instance.tow_plane)
    end 
  end
end
