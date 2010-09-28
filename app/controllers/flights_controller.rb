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
        format.html { redirect_to(edit_flight_path(@flight)) }
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
        format.html { redirect_to(@flight) }
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
