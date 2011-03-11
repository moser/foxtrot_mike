class WireLauncherCostCategoryMembership < ActiveRecord::Base
  belongs_to :wire_launcher
  belongs_to :wire_launcher_cost_category
  include ValidityCheck

  validates_presence_of :wire_launcher_cost_category, :wire_launcher
  
  def find_concerned_accounting_entry_owners(&blk)
    wire_launcher.find_concerned_accounting_entry_owners { |r| blk.call(r).between(valid_from, valid_to) }
  end
end
