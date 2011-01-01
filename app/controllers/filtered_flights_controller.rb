class FilteredFlightsController < ApplicationController
  javascript :timepicker, :groupable, :filtered_flights
  stylesheet :filtered_flights

  GROUPS = %w(planes people groups licenses purposes)

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
    p @flights.size
    @from ||= Flight.latest_departure(@flights).to_date
    @to ||= @from
    @flights = @flights.where(AbstractFlight.arel_table[:departure].gteq(@from.to_datetime)).
                          where(AbstractFlight.arel_table[:departure].lt(@to.to_datetime + 1.day)).
                          order('departure ASC').all
    p @flights.size
    if params[:group_by] && GROUPS.include?(params[:group_by]) && !request.xhr?
      @group_by = params[:group_by]
      @flights = @flights.group_by &:"grouping_#{params[:group_by]}"
    else
      @group_by = ''
    end
    if request.xhr?
#      render
#    else 
      render :partial => "filtered_flights/index", :locals => { :flights => @flights }
    end
  end
end
