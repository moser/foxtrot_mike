class FlightCostItem < ActiveRecord::Base
  belongs_to :flight_cost_rule
  belongs_to :financial_account

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
end
