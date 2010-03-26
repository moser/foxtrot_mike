class WireLauncherCostCategoryMembership < ActiveRecord::Base
  belongs_to :wire_launcher
  belongs_to :wire_launcher_cost_category
  include ValidityCheck
end
