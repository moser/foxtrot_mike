require "csv" if RUBY_VERSION =~ /^1\.9/

class AccountingSessionsController < ResourceController
  javascript :timepicker

  def show
    model_by_id
    authorize! :read, model_class
    respond_to do |f|
      f.html { render }
      f.txt do
          attr = ActiveSupport::OrderedHash.new
          attr[:voucher_date] = lambda { |i| I18n.l(@accounting_session.accounting_date, :format => :default) }
          attr[:voucher_circle] = lambda { |i| "" }
          attr[:voucher_id] = lambda { |i| @accounting_session.voucher_number }
          attr[:text] = lambda { |i| "#{@accounting_session.name}" + (i.manual? && i.text && i.text != "" ? " - #{i.text}" : "") }
          attr[:value] = lambda { |i| (i.value / 100.0).to_s.gsub(".", ",") }
          attr[:from] = lambda { |i| i.from.number }
          attr[:to] = lambda { |i| i.to.number }

          csv_string = (RUBY_VERSION =~ /^1\.9/ ? CSV : FasterCSV).generate(:col_sep => ";", :row_sep => "\r\n", :quote_char => '"', :force_quotes => true) do |csv|
            @accounting_session.aggregated_entries.each do |e|
              csv << attr.map { |k, a| a.call(e) }
            end
          end

          send_data csv_string, :type => 'text/plain; charset=utf8;',
                    :filename => "#{ @accounting_session.finished_at.to_date }-#{ AccountingSession.l(:entries) }-#{@accounting_session.voucher_number}-#{ @accounting_session.name.gsub(" ", "-") }.txt"
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
          booking.text = "dkfj"
          dta.add( booking )
        end

        send_data dta.create, :type => 'text/plain; charset=utf8;', :filename => "#{@accounting_session.voucher_number}.dtaus"
      end
    end
  end
end
