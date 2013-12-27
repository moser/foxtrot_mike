class DtaCreator < DirectDebitFileCreator
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
end
