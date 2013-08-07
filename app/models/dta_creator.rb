class DtaCreator
  def initialize(accounting_session)
    @accounting_session = accounting_session
  end

  def create
    dta = KingDta::Dtaus.new('LK')
    dta.account = KingDta::Account.new(:bank_account_number => @accounting_session.credit_financial_account.bank_account_number,
                                       :owner_name => @accounting_session.credit_financial_account.bank_account_holder,
                                       :bank_number => @accounting_session.credit_financial_account.bank_code)
    @accounting_session.accounting_entries.each do |accounting_entry|
      rec_acnt = KingDta::Account.new(:bank_account_number => accounting_entry.to.bank_account_number,
                                       :owner_name => accounting_entry.to.bank_account_holder,
                                       :bank_number => accounting_entry.to.bank_code)
      booking = KingDta::Booking.new(rec_acnt, accounting_entry.value.to_f / 100.0)
      booking.text = booking_text(accounting_entry.to)
      p booking.text
      dta.add(booking)
    end

    dta.create
  end

  def booking_text(account)
    concerned_entries(account).map(&:category_text).uniq.join(" ")
  end

  def concerned_entries(account)
    accounting_entries = account.accounting_entries_from.select do |accounting_entry| 
      accounting_entry.accounting_session &&
      accounting_entry.accounting_session.accounting_date &&
      accounting_entry.accounting_session.accounting_date >= last_debit_date
    end
  end
    
  def last_debit_date
    AccountingSession.where(bank_debit: true).order('accounting_date DESC').first.try(:accounting_date) || Time.new(0).to_date
  end
end
