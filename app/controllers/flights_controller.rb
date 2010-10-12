class FlightsController < ApplicationController
  include TimelineStuff
  #include Rails.application.routes.url_helpers

  javascript :flights, :timepicker
  #stylesheet :flights
  #before_filter :login_required
  
  # GET /flights
  # GET /flights.xml
  def index
    if params[:plane_id]
      bordbook
    elsif params[:license_id]
      flightbook
    elsif params[:airfield_id]
      @airfield = Airfield.find(params[:airfield_id])
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
      @flights = Flight.where(Flight.arel_table[:departure].gteq(@date.to_datetime)).
                         where(Flight.arel_table[:departure].lt((@date + 1.day).to_datetime)).
                         where(Flight.arel_table[:from_id].eq(@airfield.id).
                               or(Flight.arel_table[:to_id].eq(@airfield.id))).
                         order("departure ASC")
      if params[:as].nil? || params[:as] == 'main_flight_book'
        render :template => "flights/main_flight_book"
      elsif params[:as] == 'controller_log'
        @controllers = []
        if @flights.count > 0
          c = nil
          @flights.each do |f|
            if c != f.controller
              c = f.controller
              if @controllers.last
                @controllers.last[:to] = f.departure
              end
              @controllers << { :person => f.controller, :from => f.departure, :to => f.departure }
            end
          end
          @controllers.last[:to] = (@flights.map(&:arrival).select { |a| !a.nil? }).max
        end
        render :template => "flights/controller_log"
      end
    elsif params[:group_id]
      javascript :filtered_flights
      stylesheet :filtered_flights
      p params
      if params[:filter]
        if !params[:filter]['from(1i)'].nil?
          @from, @to = ['from', 'to'].map do |attr|
            Date.new(params[:filter]["#{attr}(1i)"].to_i, params[:filter]["#{attr}(2i)"].to_i, params[:filter]["#{attr}(3i)"].to_i)
          end
        end
 
      end
      @flights = Flight.include_all.where(Flight.arel_table[:id].in(CrewMember.arel_table.join(Person.arel_table).on(CrewMember.arel_table[:person_id].eq(Person.arel_table[:id])).where(CrewMember.arel_table[:type].in(['Trainee', 'PilotInCommand', 'Instructor'])).where(Person.arel_table[:group_id].eq(params[:group_id])).project(CrewMember.arel_table[:abstract_flight_id])))
      unless @from
        @from = @to = Flight.latest_departure(@flights).to_date
      end
      @flights = @flights.where(Flight.arel_table[:departure].gteq(@from.to_datetime)).
                            where(Flight.arel_table[:departure].lt(@to.to_datetime + 1.day)).
                            order('departure ASC').all
      if params[:group_by] && !request.xhr?
        @flights = @flights.group_by &:"#{params[:group_by]}"
      end
      unless request.xhr?
        render :template => "flights/filtered_flights"
      else 
        render :partial => "flights/filtered_flights", :locals => { :flights => @flights }
      end
    else
      javascript :stay_on_page
      @flights = Flight.includes(:plane, :from, :to, :crew_members).paginate :per_page => 5, :page => params[:page], :order => 'created_at DESC'
      respond_to do |format|
        format.html { render :layout => !request.xhr? }
        format.json { render :json => @flights }
      end
    end
  end

  def bordbook
    @plane_id = params[:plane_id]
    setup_vars(Flight.includes(:plane, :from, :to, :crew_members).order("departure, created_at ASC").where(:plane_id => @plane_id))
    @timeline_locals = timeline_locals([@url_obj = Plane.find(@plane_id), :flights])
    book(true)
  end

  def flightbook
    @license_id = params[:license_id]
    @url_obj = license = License.find(@license_id)
    setup_vars(license.flights)
    @timeline_locals = timeline_locals([@url_obj, :flights])  
    book(false)
  end

  def book(group = false)
    stylesheet :book, :timeline
    javascript :book

    if @from && @to   
      @calculated_flights = []
      group_id = ""
      @flights_for_timeline.each do |f|
        if f.departure_date > @from && f.departure_date <= @to
          if group
            if group_id != f.group_id
              group_id = f.group_id
              @calculated_flights << { :group_id => group_id, :flights => [] }
            end
          else
            @calculated_flights << { :group_id => 'none', :flights => [] }
          end
          @calculated_flights.last[:flights] << f
        end
      end
    end
    unless request.xhr?
      render :template => 'flights/bordbook'
    else
      render :partial => 'flights/bordbook',
             :locals => { :calculated_flights => @calculated_flights }, :layout => false
    end
  end

  # GET /flights/1
  # GET /flights/1.xml
  def show
    javascript :asdklfas
    @flight = AbstractFlight.find(params[:id], :include => [:plane, :from, :to, :crew_members])

    respond_to do |format|
      format.html do
        if request.xhr?
          render :layout => false
        end
      end
      format.json  { render :json => @flight }
    end
  end

  # GET /flights/new
  # GET /flights/new.xml
  def new
    @flight = Flight.new

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.json { render :json => @flight }
    end
  end

  # GET /flights/1/edit
  def edit
    @flight = AbstractFlight.find(params[:id])
    if request.xhr?
      render :layout => false
    end
  end

  # POST /flights
  # POST /flights.xml
  def create
    #TODO what to do with type? new controller or split here
    attrs = params[:flight] #|| params[:tow_flight]
    @flight = (attrs.delete(:type) || "Flight").constantize.new(attrs)
    @flight.id = attrs[:id] unless attrs[:id].nil?
    respond_to do |format|
      if @flight.save
        flash[:notice] = 'Flight was successfully created.'
        format.html do
          unless request.xhr?
            redirect_to(flight_path(@flight))
          else
            render :action => :show, :layout => false
          end
        end
        format.json  { render :json => @flight, :status => :created, :location => @flight }
      else
        format.html { render :action => "new", :layout => !request.xhr? }
        format.json  { render :json => @flight.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /flights/1
  # PUT /flights/1.xml
  def update
    @flight = AbstractFlight.find(params[:id])
    respond_to do |format|
      if @flight.update_attributes(params[:flight])
        flash[:notice] = 'Flight was successfully updated.'
        format.html do
          unless request.xhr?
            redirect_to(flight_path(@flight))
          else
            render :action => :show, :layout => false
          end
        end
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @flight.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /flights/1
  # DELETE /flights/1.xml
  def destroy
    @flight = AbstractFlight.find(params[:id])
    @flight.destroy

    respond_to do |format|
      format.html { redirect_to(flights_url) }
      format.json  { head :ok }
    end
  end

private
  def load_flights
    @flights = Flight.includes(:plane, :from, :to, :crew_members).all
  end
end
