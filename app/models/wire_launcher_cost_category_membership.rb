class WireLauncherCostCategoryMembership < ActiveRecord::Base
  belongs_to :wire_launcher
  belongs_to :wire_launcher_cost_category
  include ValidityCheck

  validates_presence_of :wire_launcher_cost_category, :wire_launcher
end
