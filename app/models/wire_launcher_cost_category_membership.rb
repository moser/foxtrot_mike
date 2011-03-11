class WireLauncherCostCategoryMembership < ActiveRecord::Base
  include ValidityCheck
  include AccountingEntryInvalidation
  include Immutability
  
  belongs_to :wire_launcher
  belongs_to :wire_launcher_cost_category
  immutable :wire_launcher, :wire_launcher_cost_category

  validates_presence_of :wire_launcher_cost_category, :wire_launcher
  
  def find_concerned_accounting_entry_owners(&blk)
    wire_launcher.find_concerned_accounting_entry_owners { |r| blk.call(r).between(valid_from, valid_to) }
  end
end
