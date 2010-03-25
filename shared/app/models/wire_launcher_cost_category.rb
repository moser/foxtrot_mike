class WireLauncherCostCategory < ActiveRecord::Base
  has_many :wire_launchers
  has_many :wire_launch_cost_rules
end
