class WireLaunchCostRule < ActiveRecord::Base
  belongs_to :wire_launcher_cost_category
  belongs_to :person_cost_category
  include ValidityCheck
  
  validates_presence_of :cost, :wire_launcher_cost_category, :person_cost_category
end
