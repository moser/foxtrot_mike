class PersonCostCategoryMembership < ActiveRecord::Base
  include ValidityCheck  
  include Immutability
  include AccountingEntryInvalidation
  
  after_save :after_save_invalidate_accounting_entries
  
  belongs_to :person_cost_category
  belongs_to :person
  immutable :person, :person_cost_category

  validates_presence_of :person, :person_cost_category
  
  def find_concerned_accounting_entry_owners(from = valid_from, to = valid_to, &blk)
    blk ||= lambda { |r| r }
    person.find_concerned_accounting_entry_owners { |r| blk.call(r).between(min_date(valid_from, from), max_date(valid_to, to)) }
  end
  
private
  def after_save_invalidate_accounting_entries
    created = changes.keys.include?("id")
    if created
      delay.invalidate_concerned_accounting_entries
    else
      delay.invalidate_concerned_accounting_entries(old_or_current(:valid_from), old_or_current(:valid_to))
    end
  end
end
