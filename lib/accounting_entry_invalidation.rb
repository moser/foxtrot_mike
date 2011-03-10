module AccountingEntryInvalidation
  def invalidate_concerned_accounting_entries
    find_concerned_accounting_entry_owners.each do |o|
      o.invalidate_accounting_entries(false)
    end
  end
  
  def max_date(a, b)
    if a && b
      a > b ? a : b
    else
      nil
    end
  end
  
  def min_date(a, b)
    if a && b
      a < b ? a : b
    else
      nil
    end
  end
end
