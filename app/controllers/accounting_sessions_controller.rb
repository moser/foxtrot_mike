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
        dta = DtaCreator.new(@accounting_session)
        send_data dta.create, :type => 'text/plain; charset=utf8;', :filename => "#{@accounting_session.voucher_number}.dtaus"
      end
      f.sepa do
        sepa = SepaCreator.new(@accounting_session)
        send_data sepa.create(params[:filter]), :type => 'text/plain; charset=utf8;', :filename => "#{@accounting_session.voucher_number}.#{params[:filter]}.xml"
      end
    end
  end
end
