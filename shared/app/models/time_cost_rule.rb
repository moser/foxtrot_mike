class TimeCostRule < ActiveRecord::Base
  belongs_to :plane_cost_category
  belongs_to :person_cost_category
  include ValidityCheck
  
  def cost_for(flight)
    [ (flight.send(depends_on) * cost) + additive_cost, 0 ].max
  end
  
  def matches?(flight)
    if !condition_field.nil? && !condition_operator.nil?
      i = flight.send(condition_field)
      if i.is_a?(Fixnum)
        i.send(condition_operator, condition_value)
      else #hmm
        false
      end
    else
      true # => no condition
    end
  end
end
