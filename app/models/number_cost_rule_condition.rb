class NumberCostRuleCondition < CostRuleCondition
  def self.valid_fields
    ["duration", "engine_duration"]
  end

  def self.valid_operators
    [ ">", "<", "==", ">=", "<=" ]
  end

  validates_presence_of :condition_field, :condition_operator, :condition_value_i
  validates_numericality_of :condition_value_i, :only_integer => true
  validates_inclusion_of :condition_field, :in => valid_fields
  validates_inclusion_of :condition_operator, :in => valid_operators

  def matches?(flight)
    unless condition_field.nil? || condition_operator.nil? || condition_value_i.nil?
      i = flight.send(condition_field)
      i.send(condition_operator, condition_value_i)
    else
      false # better find fewer flights
    end
  end
end
