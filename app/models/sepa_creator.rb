class SepaCreator < DirectDebitFileCreator
  def create(filter)
    sdd = SEPA::DirectDebit.new(name: @accounting_session.credit_financial_account.bank_account_holder,
                                bic:  @accounting_session.credit_financial_account.bic.gsub(/\s/, ''),
                                iban: @accounting_session.credit_financial_account.iban.gsub(/\s/, ''),
                                creditor_identifier: @accounting_session.credit_financial_account.creditor_identifier)

    @accounting_session.accounting_entries.each do |accounting_entry|
      if accounting_entry.to.sequence_type(@accounting_session) == filter
        sdd.add_transaction(
          name:                      accounting_entry.to.bank_account_holder,
          bic:                       accounting_entry.to.bic.gsub(/\s/, ''),
          iban:                      accounting_entry.to.iban.gsub(/\s/, ''),
          amount:                    accounting_entry.value.to_f / 100.0,
          remittance_information:    booking_text(accounting_entry.to),
          mandate_id:                accounting_entry.to.mandate_id,
          mandate_date_of_signature: accounting_entry.to.mandate_date_of_signature,
          sequence_type: accounting_entry.to.sequence_type(@accounting_session), 
          local_instrument: 'CORE',
          # OPTIONAL: Requested collection date, in German "Fälligkeitsdatum der Lastschrift"
          # Date
          # requested_date: Date.new(2013,9,5),
          batch_booking: true)
      end
    end

    sdd.to_xml


   # dta.account = KingDta::Account.new(:bank_account_number => @accounting_session.credit_financial_account.bank_account_number,
   #                                    :owner_name => @accounting_session.credit_financial_account.bank_account_holder,
   #                                    :bank_number => @accounting_session.credit_financial_account.bank_code)
   #   rec_acnt = KingDta::Account.new(:bank_account_number => accounting_entry.to.bank_account_number,
   #                                    :owner_name => accounting_entry.to.bank_account_holder,
   #                                    :bank_number => accounting_entry.to.bank_code)
  end
end
