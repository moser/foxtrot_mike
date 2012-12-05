class FlightsController < ApplicationController
  def index
    authorize! :read, AbstractFlight
    @flights = AbstractFlight.where(departure_date: AbstractFlight.latest_departure.to_date)
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
    puts params[:flight].to_yaml
    flight = AbstractFlight.find(params[:id])
    authorize! :update, flight
    flight.update_attributes!(params[:flight].select { |k,_| flight.class.writable_attributes.include?(k.to_sym) })
    render json: flight
  end

  def create
    authorize! :create, Flight
    flight_klass = (params[:flight][:type] ? params[:flight][:type].constantize : Flight)
    flight = flight_klass.create(params[:flight].select { |k,_| flight_klass.writable_attributes.include?(k.to_sym) })
    render json: flight
  end
end
