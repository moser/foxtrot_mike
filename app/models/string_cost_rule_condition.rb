class StringCostRuleCondition < CostRuleCondition
  def matches?(flight)
    unless condition_field.nil? || condition_value_s.nil?
      i = flight.send(condition_field)
      i == condition_value_s
    else
      false # better find fewer flights
    end
  end
end
