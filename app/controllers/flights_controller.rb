class FlightsController < ApplicationController
  def index
    @flights = AbstractFlight.where(departure_date: AbstractFlight.latest_departure.to_date)
    respond_to do |f|
      f.html do
        @people = Person.all
        @airfields = Airfield.all
        @planes = Plane.all
      end
      f.json { render json: @flights }
    end
  end
end
