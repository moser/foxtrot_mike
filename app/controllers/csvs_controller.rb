class CsvsController < ApplicationController
  def create
    authorize! :read, Flight
    @flights = AbstractFlight.reverse_order.where("id in (?)", JSON.parse(params[:flight_ids]))
    send_data FlightExporter.new(@flights).to_csv, type: :csv, filename: 'flights.csv'
  end
end
