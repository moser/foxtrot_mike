class PurposeCostRuleCondition < CostRuleCondition
  attr_accessible :cost_rule, :cost_rule_id, :purpose_filter

  validates_presence_of :purpose_filter

  def matches?(flight)
    flight.purpose.to_s == self.purpose_filter.to_s
  end
end
