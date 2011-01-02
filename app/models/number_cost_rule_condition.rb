class NumberCostRuleCondition < CostRuleCondition
  def matches?(flight)
    unless condition_field.nil? || condition_operator.nil? || condition_value_i.nil?
      i = flight.send(condition_field)
      i.send(condition_operator, condition_value_i)
    else
      false # better find fewer flights
    end
  end
end
