class PdfsController < ApplicationController
  def create
    authorize! :read, Flight
    @flights = AbstractFlight.reverse_order.where("id in (?)", JSON.parse(params[:flight_ids]))
    render :pdf => "flights",
           :template => "flights/_grouped.html.haml",
           :disable_internal_links => true,
           :disable_external_links => true,
           :dpi => "90",
           :orientation => "landscape"
  end
end
