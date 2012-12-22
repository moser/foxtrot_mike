class PlaneCostCategoryMembership < ActiveRecord::Base
  include ValidityCheck
  include Immutability
  include AccountingEntryInvalidation
  
  after_save :after_save_invalidate_accounting_entries
  
  belongs_to :plane
  belongs_to :plane_cost_category
  immutable :plane, :plane_cost_category

  validates_presence_of :plane, :plane_cost_category
  
  def find_concerned_accounting_entry_owners(from = valid_from, to = valid_to, &blk)
    blk ||= lambda { |r| r }
    plane.find_concerned_accounting_entry_owners { |r| blk.call(r).between(min_date(valid_from, from), max_date(valid_to, to)) }
  end
  
private
  def after_save_invalidate_accounting_entries
    created = changes.keys.include?("id")
    if created
      invalidate_concerned_accounting_entries
    else
      invalidate_concerned_accounting_entries(old_or_current(:valid_from), old_or_current(:valid_to))
    end
  end
end
