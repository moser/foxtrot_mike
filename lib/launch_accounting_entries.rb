module LaunchAccountingEntries
  def create_accounting_entries
    accounting_entries_without_validity_check.destroy_all
    if cost
      sum = cost.free_sum
      abstract_flight.liabilities_with_default.map do |l|
        value = (abstract_flight.proportion_for(l) * sum).round
        unless value == 0
          AccountingEntry.create(:from => l.person.financial_account_at(departure_date), :to => financial_account,
                                 :value => value, :item => self)
        end
      end
      cost.bound_items.map do |i|
        unless i.value == 0
          AccountingEntry.create(:from => i.financial_account, :to => financial_account,
                                 :value => i.value, :item => self)
        end
      end
    end
    update_attribute :accounting_entries_valid, true
  end

  def invalidate_accounting_entries
    if abstract_flight.editable?
      update_attribute :accounting_entries_valid, false
    end
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
