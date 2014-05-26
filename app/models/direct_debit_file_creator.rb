class DirectDebitFileCreator
  def initialize(accounting_session)
    @accounting_session = accounting_session
  end

  def booking_text(account)
    "#{@accounting_session.name} #{concerned_entries(account).map(&:category_text).uniq.join("; ")}"
  end

  def concerned_entries(account)
    accounting_entries = account.accounting_entries_from.select do |accounting_entry| 
      accounting_entry.accounting_session &&
      accounting_entry.accounting_session.accounting_date &&
      accounting_entry.accounting_session.accounting_date > last_debit_date
    end
  end
    
  def last_debit_date
    AccountingSession.where(bank_debit: true).where('accounting_date < ?', @accounting_session.accounting_date).maximum(:accounting_date) || Time.new(0).to_date
  end
end
