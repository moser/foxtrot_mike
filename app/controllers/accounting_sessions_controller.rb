require "csv" if RUBY_VERSION =~ /^1\.9/

class AccountingSessionsController < ResourceController
  javascript :timepicker

  def show
    model_by_id
    authorize! :read, model_class
    respond_to do |f|
      f.html { render }
      f.txt do
          send_data @accounting_session.bookings_csv, :type => 'text/plain; charset=utf8;',
                    :filename => @accounting_session.filename
      end
      f.pdf do
          render :pdf => "#{@accounting_session.voucher_number}",
                 :template => "accounting_sessions/voucher.html.haml",
                 :disable_internal_links => true,
                 :disable_external_links => true,
                 :dpi => "90"
      end
      f.dtaus do
        dta = KingDta::Dtaus.new('LK')
        dta.account = KingDta::Account.new(:bank_account_number => @accounting_session.credit_financial_account.bank_account_number,
                                           :owner_name => @accounting_session.credit_financial_account.bank_account_holder,
                                           :bank_number => @accounting_session.credit_financial_account.bank_code)
        @accounting_session.accounting_entries.each do |a|
          rec_acnt = KingDta::Account.new(:bank_account_number => a.to.bank_account_number,
                                           :owner_name => a.to.bank_account_holder,
                                           :bank_number => a.to.bank_code)
          booking = KingDta::Booking.new(rec_acnt, a.value.to_f / 100.0)
          booking.text = @accounting_session.name
          dta.add( booking )
        end

        send_data dta.create, :type => 'text/plain; charset=utf8;', :filename => "#{@accounting_session.voucher_number}.dtaus"
      end
    end
  end
end
