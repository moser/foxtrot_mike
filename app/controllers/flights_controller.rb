class FlightsController < ApplicationController
  #before_filter :login_required
  
  # GET /flights
  # GET /flights.xml
  def index
    @flights = Flight.all
    
    respond_to do |format|
      format.html { render :layout => 'application' }
      format.json  { render :json => @flights }
    end
  end

  # GET /flights/1
  # GET /flights/1.xml
  def show
    @flight = AbstractFlight.find(params[:id])

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
      format.html # new.html.erb
      format.json  { render :json => @flight }
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
        format.html { render :action => "new" }
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
end
