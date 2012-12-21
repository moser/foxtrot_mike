class PdfsController < ApplicationController
  def create
    authorize! :read, Flight
    @flights = AbstractFlight.reverse_order.where("id in (?)", JSON.parse(params[:flight_ids]))
    render_pdf
  end

  #main log book
  def show
    authorize! :read, Flight
    scope = Airfield.find(params[:airfield_id]).flights
    p scope.to_sql
    @flights = scope.where("departure_date = ?", AbstractFlight.latest_departure(scope).to_date)
    render_pdf
  end

  def render_pdf
    render :pdf => "flights",
           :template => "flights/_grouped.html.haml",
           :disable_internal_links => true,
           :disable_external_links => true,
           :dpi => "90",
           :orientation => "landscape"
  end
end
