class FlightsController < ApplicationController
  def index
    authorize! :read, AbstractFlight
    @flights = AbstractFlight.scoped
    if params[:filter_model] && params[:filter_id]
      raise "Nope" unless %w(Group Plane Person).include?(params[:filter_model])
      @flights = params[:filter_model].constantize.find(params[:filter_id]).flights
    end
    if params[:range]
      min, max = params[:range].split(".").map { |s| Date.parse(s) }.sort
      @flights = @flights.where("departure_date <= ? AND departure_date >= ?", max, min)
    else
      @flights = @flights.limit(40)
    end
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
