class FlightsController < ApplicationController
  #include Rails.application.routes.url_helpers

  javascript :flights, :timepicker
  #stylesheet :flights
  #before_filter :login_required
  
  # GET /flights
  # GET /flights.xml
  def index
    authorize! :read, Flight
    javascript :stay_on_page, :lala
    if !request.xhr?
      @dates = AbstractFlight.group("date(departure)").order("date(departure) DESC").count
    end
    @flights = AbstractFlight.include_all.paginate :per_page => 25, :page => params[:page], :order => 'departure DESC, created_at DESC'
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.json { render :json => @flights }
    end
  end  

  # GET /flights/1
  # GET /flights/1.xml
  def show
    javascript :lala
    @flight = AbstractFlight.find(params[:id], :include => [:plane, :from, :to, :crew_members])
    authorize! :read, @flight
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.json { render :json => @flight }
    end
  end

  # GET /flights/new
  # GET /flights/new.xml
  def new
    @flight = Flight.new
    authorize! :create, Flight
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.json { render :json => @flight }
    end
  end

  # GET /flights/1/edit
  def edit
    @flight = AbstractFlight.find(params[:id])
    authorize! :update, @flight
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
    authorize! :create, @flight
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
        p @flight.errors
        format.html { render :action => "new", :layout => !request.xhr? }
        format.json  { render :json => @flight.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /flights/1
  # PUT /flights/1.xml
  def update
    @flight = AbstractFlight.find(params[:id])
    authorize! :update, @flight
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
    authorize! :destroy, @flight
    @flight.destroy
    
    respond_to do |format|
      format.html { redirect_to(flights_url) }
      format.json  { head :ok }
    end
  end
end
