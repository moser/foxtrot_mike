class WireLaunchCostRule < ActiveRecord::Base
  belongs_to :wire_launcher_cost_category
  belongs_to :person_cost_category
  include ValidityCheck
end
