module LaunchAccountingEntries
  def create_accounting_entries
    accounting_entries_without_validity_check.delete_all
    if cost
      sum = cost.free_sum
      abstract_flight.liabilities_with_default.map do |l|
          AccountingEntry.create(:from => l.person.financial_account, :to => financial_account, 
                                   :value => (abstract_flight.proportion_for(l) * sum).round, :item => self)
      end
      cost.bound_items.map { |i| AccountingEntry.create(:from => i.financial_account, :to => financial_account,
                                                          :value => i.value, :item => self) }
    end
    update_attribute :accounting_entries_valid, true
  end
  
  def invalidate_accounting_entries(delayed = true)
    update_attribute :accounting_entries_valid, false
    (delayed ? delay : self).create_accounting_entries
  end
  
  def accounting_entries_with_validity_check
    unless accounting_entries_valid?
      create_accounting_entries
    end
    accounting_entries_without_validity_check(true)
  end
  
  def self.included(base)
    base.alias_method_chain :accounting_entries, :validity_check
  end
end
