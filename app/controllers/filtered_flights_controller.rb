require "csv" if RUBY_VERSION =~ /^1\.9/

class FilteredFlightsController < ApplicationController
  include ApplicationHelper
  javascript :timepicker, :filtered_flights
  stylesheet :filtered_flights

  GROUPS = %w(planes people groups licenses purposes)

  # TODO split and spec
  def index
    authorize! :read, :filtered_flights
    if params[:filter]
      @from, @to = parse_date(params[:filter], :from), parse_date(params[:filter], :to)
    end

    if params[:plane_id]
      @obj = Plane.find(params[:plane_id])
    elsif params[:person_id]
      @obj = Person.find(params[:person_id])
    elsif params[:license_id]
      @obj = License.find(params[:license_id])
    elsif params[:group_id]
      @obj = Group.find(params[:group_id])
    else
      @obj = Struct.new("Hua", :to_s, :flights).new("Alle", AbstractFlight.include_all)
    end

    @flights = @obj.flights
    @from ||= Flight.latest_departure(@flights).to_date
    @to ||= @from
    @flights = @flights.where(AbstractFlight.arel_table[:departure_date].gteq(@from.to_date)).
                          where(AbstractFlight.arel_table[:departure_date].lteq(@to.to_date)).
                          order('departure_date ASC, departure_i ASC').all

    if params[:group_by] && GROUPS.include?(params[:group_by]) && !request.xhr?
      @group_by = params[:group_by]
      @flights = @flights.group_by &:"grouping_#{params[:group_by]}"
      @flights.delete_if { |a| a && a.respond_to?(:id) && params[:ignore].include?(a.id) } if params[:ignore]
    else
      @group_by = ''
    end
    if request.xhr?
      render :partial => "filtered_flights/index", :locals => { :flights => @flights, :aggregate_entries => false }
    else
      @aggregate_entries = !!params[:aggregate_entries]
      respond_to do |f|
        f.csv do
          attr = ActiveSupport::OrderedHash.new
          attr[:departure_date] = lambda { |i| I18n.l(i) }
          attr[:seat1] = lambda { |i| i.to_s } 
          attr[:seat2] = lambda { |i| i.to_s }
          attr[:launch_type_short] = lambda { |i| i.to_s }
          attr[:purpose] = lambda { |i| i.to_s }
          attr[:from] = lambda { |i| i.to_s }
          attr[:to] = lambda { |i| i.to_s }
          attr[:departure_time] = lambda { |i| format_minutes(i) }
          attr[:arrival_time] = lambda { |i| format_minutes(i) }
          attr[:duration] = lambda { |i| format_minutes(i) }

          csv_string = (RUBY_VERSION =~ /^1\.9/ ? CSV : FasterCSV).generate(:quote_char => '"', :force_quotes => true) do |csv|
            csv << attr.keys.map { |e| Flight.l(e) }

            if @group_by == ''
              @flights.each do |f|
                csv << attr.map { |e, p| p.call(f.send(e)) }
              end
              csv << [@flights.size, format_minutes(@flights.map { |e| e.duration }.sum)]
            else
              @flights.keys.each do |k|
                csv << [k]
                @flights[k].each do |f|
                  csv << attr.map { |e, p| p.call(f.send(e)) }
                end
                csv << [@flights[k].size, format_minutes(@flights[k].map { |e| e.duration }.sum)]
                csv << []
              end
            end
          end

          send_data csv_string, :type => 'text/csv; charset=utf8;', :filename => "#{@obj.to_s}-flights.csv".downcase.gsub(" ", "-")
        end
        f.pdf {
          render :pdf => "#{@obj.to_s}-flights".downcase.gsub(" ", "-"),
                 :template => "filtered_flights/index.html.haml",
                 :disable_internal_links => true,
                 :disable_external_links => true
        }
        f.html { render }
      end
    end
  end
end
