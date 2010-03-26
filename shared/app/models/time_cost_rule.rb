class TimeCostRule < ActiveRecord::Base
  belongs_to :plane_cost_category
  belongs_to :person_cost_category
  include ValidityCheck
  
  def cost_for(flight)
    flight.send(depends_on) * cost
  end
end
