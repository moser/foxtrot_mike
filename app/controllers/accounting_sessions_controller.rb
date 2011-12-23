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
          attr[:voucher_date] = lambda { |i| I18n.l(@accounting_session.finished_at.to_date, :format => :default) }
          attr[:voucher_circle] = lambda { |i| "FM" }
          attr[:voucher_id] = lambda { |i| @accounting_session.id }
          attr[:text] = lambda { |i| "Flugabrechnung " + @accounting_session.name }
          attr[:value] = lambda { |i| (i.value / 100.0).to_s.gsub(".", ",") }
          attr[:from] = lambda { |i| i.from.number }
          attr[:to] = lambda { |i| i.to.number }

          csv_string = (RUBY_VERSION =~ /^1\.9/ ? CSV : FasterCSV).generate(:col_sep => ";", :row_sep => "\r\n", :quote_char => '"', :force_quotes => true) do |csv|
            @accounting_session.aggregated_entries.each do |e|
              csv << attr.map { |k, a| a.call(e) }
            end
          end

          send_data csv_string, :type => 'text/plain; charset=utf8;',
                    :filename => "#{ @accounting_session.finished_at.to_date }-#{ AccountingSession.l(:entries) }-#{ @accounting_session.name.gsub(" ", "-") }.txt"
      end
    end
  end
end
