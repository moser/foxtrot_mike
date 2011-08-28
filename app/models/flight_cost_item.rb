class FlightCostItem < ActiveRecord::Base
  after_update :after_update_invalidate_accounting_entries
  
  def self.valid_fields
    [ nil, "duration", "engine_duration" ]
  end

  belongs_to :flight_cost_rule
  belongs_to :financial_account

  validates_inclusion_of :depends_on, :in => valid_fields
  validates_presence_of :flight_cost_rule

  def apply_to(flight)
    v = [ apply_depending_value(flight) + additive_value, 0 ].max
    CostItem.new(self, v, financial_account)
  end

  def additive_value
    read_attribute(:additive_value) || 0
  end

  def apply_depending_value(flight)
    unless depends_on.nil? || value.nil?
      flight.send(depends_on) * value
    else
      0
    end
  end
  
private
  def after_update_invalidate_accounting_entries
    flight_cost_rule.association_changed(nil)
  end
end
