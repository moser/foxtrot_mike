class FlightsController < ApplicationController
  #include Rails.application.routes.url_helpers

  javascript :flights, :timepicker
  #stylesheet :flights
  #before_filter :login_required

  def dates
    @dates ||= AbstractFlight.where("departure_date > ?", 2.years.ago).group("departure_date").order("departure_date DESC").count unless request.xhr?
  end

  # GET /flights
  # GET /flights.xml
  def index
    authorize! :read, Flight
    javascript :lala
    @current_day = Date.new(*(["day(1i)", "day(2i)", "day(3i)"].map { |e| params[e].to_i })) if params["day(1i)"]
    @current_day ||= AbstractFlight.latest_departure.to_date
    dates
    if !request.xhr?
      @flights = AbstractFlight.include_all.where("departure_date = ?", @current_day).
                                  order("departure_date DESC, departure_i DESC, type DESC, id DESC")
    else
      from = @current_day
      to = @current_day + 1.day
      if params[:minus_days]
        from = AbstractFlight.group("departure_date").order("departure_date DESC").
                                where("departure_date <= ?", @current_day).limit(params[:minus_days]).
                                count.keys.min || @current_day
      end
      if params[:plus_days]
        to = (AbstractFlight.group("departure_date").order("departure_date ASC").
                          where("departure_date >= ?", @current_day + 1.day).limit(params[:plus_days]).
                          count.keys.max || @current_day) + 1.day
      end
      @days = AbstractFlight.include_all.where("departure_date >= ? and departure_date <= ?", from, to).
                               order("departure_date DESC, departure_i  DESC, type DESC, id DESC").group_by { |f| f.departure_date }
      (from..(to - 1.day)).each do |d|
        @days[d] ||= []
      end
    end

    respond_to do |format|
      format.html do 
        if request.xhr?
          #really_expires_now
          render :partial => "flights/days", :locals => { :days => @days} #TODO? , :terminators => [ AbstractFlight.latest_departure.to_date, AbstractFlight.oldest_departure.to_date ] }
        end
      end
      format.json { render :json => @flights }
    end
  end

  # GET /flights/1
  # GET /flights/1.xml
  def show
    javascript :lala
    @flight = AbstractFlight.find(params[:id], :include => [:plane, :from, :to, :crew_members])
    authorize! :read, @flight
    dates
    respond_to do |format|
      format.html do
        really_expires_now if request.xhr?
        render :layout => !request.xhr?
      end
      format.json { render :json => @flight }
    end
  end

  # GET /flights/new
  # GET /flights/new.xml
  def new
    @flight = Flight.new :from => Airfield.home.first, :to => Airfield.home.first
    authorize! :create, Flight
    dates
    @current_day = AbstractFlight.latest_departure.to_date
    respond_to do |format|
      format.html do
        really_expires_now
        render :layout => !request.xhr?
      end
      format.json { render :json => @flight }
    end
  end

  # GET /flights/1/edit
  def edit
    @flight = AbstractFlight.find(params[:id])
    authorize! :update, @flight
    dates
    if request.xhr?
      really_expires_now
      render :layout => false
    end
  end

  # POST /flights
  # POST /flights.xml
  def create
    #TODO what to do with type? new controller or split here
    attrs = params[:flight] || params[:tow_flight]
    attrs.delete_if { |k,v| k.to_s =~ /^duration/ }
    @flight = (attrs.delete(:type) || "Flight").constantize.new(attrs)
    authorize! :create, @flight
    #@flight.id = attrs[:id] unless attrs[:id].nil?
    respond_to do |format|
      if @flight.save
        format.html do
          unless request.xhr?
            flash[:notice] = 'Flight was successfully created.'
            redirect_to(flight_path(@flight))
          else
            render :text => flight_path(@flight)
          end
        end
        format.json  { render :json => "OK" }
      else
        format.html { render :action => "new", :layout => !request.xhr?, :status => :unprocessable_entity }
        format.json  { render :json => "FAIL", :status => :unprocessable_entity }
      end
    end
  end

  # PUT /flights/1
  # PUT /flights/1.xml
  def update
    attrs = params[:flight] || params[:tow_flight]
    attrs.delete_if { |k,v| k.to_s =~ /^duration/ }
    @flight = AbstractFlight.find(params[:id])
    authorize! :update, @flight
    respond_to do |format|
      if @flight.update_attributes(attrs)
        format.html do
          unless request.xhr?
            flash[:notice] = 'Flight was successfully updated.'
            redirect_to(flight_path(@flight))
          else
            render :action => :show, :layout => false
          end
        end
        format.json  { head :ok }
      else
        p @flight.errors
        format.html { render :action => "edit", :layout => !request.xhr?, :status => :unprocessable_entity }
        format.json  { render :json => @flight.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /flights/1
  # DELETE /flights/1.xml
  def destroy
    @flight = AbstractFlight.find(params[:id])
    authorize! :destroy, @flight
    @flight.destroy

    respond_to do |format|
      format.html { redirect_to(flights_url) }
      format.json  { head :ok }
    end
  end

private
  def really_expires_now
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
