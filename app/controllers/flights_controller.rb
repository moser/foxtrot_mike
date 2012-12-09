class FlightsController < ApplicationController
  def index
    authorize! :read, AbstractFlight
    @flights = AbstractFlight.order("departure_date DESC, departure_i DESC").limit(40) #.where(departure_date: AbstractFlight.latest_departure.to_date)
    respond_to do |f|
      f.html do
        @people = Person.all
        @airfields = Airfield.all
        @planes = Plane.all
        @wire_launchers = WireLauncher.all
      end
      f.json { render json: @flights }
    end
  end

  def show
    flight = AbstractFlight.find(params[:id])
    authorize! :read, flight
    render json: flight
  end

  def update
    flight = AbstractFlight.find(params[:id])
    authorize! :update, flight
    flight.update_attributes!(params[:flight].slice(*flight.class.writable_attributes))
    render json: flight
  end

  def create
    authorize! :create, Flight
    flight_klass = (params[:flight][:type] ? params[:flight][:type].constantize : Flight)
    flight = flight_klass.create(params[:flight].slice(*flight_klass.writable_attributes))
    render json: flight
  end

  def destroy
    flight = Flight.find(params[:id])
    authorize! :destroy, flight
    flight.destroy
    render json: {}
  end
end
