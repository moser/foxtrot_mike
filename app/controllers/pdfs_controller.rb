class PdfsController < ApplicationController
  def show
    authorize! :read, Flight
    @flights = AbstractFlight.reverse_order.
      where("from_id = ? OR to_id = ?", params[:airfield_id], params[:airfield_id]).
      where(departure_date: Date.parse(params[:date])) 
    render_pdf
  end

  def create
    authorize! :read, Flight
    @flights = AbstractFlight.reverse_order.where("id in (?)", JSON.parse(params[:flight_ids]))
    render_pdf
  end

  def render_pdf
    render pdf: "flights",
           template: "flights/_grouped.html.haml",
           disable_internal_links: true,
           disable_external_links: true,
           dpi: "90",
           orientation: "landscape",
           margin: { top: 15, bottom: 15, left: 20, right: 20 }
  end
end
