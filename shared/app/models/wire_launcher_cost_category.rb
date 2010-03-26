class WireLauncherCostCategory < ActiveRecord::Base
  has_many :wire_launcher_cost_category_memberships
  has_many :wire_launch_cost_rules
end
