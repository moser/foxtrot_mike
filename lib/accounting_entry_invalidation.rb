module AccountingEntryInvalidation
  def invalidate_concerned_accounting_entries(*args)
    #puts "invalidate_accounting_entries"
    find_concerned_accounting_entry_owners(*args).each do |o|
      o.invalidate_accounting_entries(false) #false => do not delay
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
  
  def old_or_current(sym)
    (changes[sym.to_s] || [self.send(sym)])[0]
  end
end
