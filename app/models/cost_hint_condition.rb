class CostHintCondition < CostRuleCondition
  attr_accessible :cost_hint, :cost_rule, :cost_rule_id, :cost_hint_id

  belongs_to :cost_hint
  validates_presence_of :cost_hint

  def matches?(flight)
    !cost_hint.nil? && flight.cost_hint == cost_hint
  end
end
