class BordbooksController < PdfsController
  def show
    flights = AbstractFlight.where(departure_date: params[:date] || AbstractFlight.latest_departure.to_date)
                            .reorder('planes.registration DESC, departure_date ASC, departure_i ASC')
    @flights_grouped = flights.to_a.group_by(&:plane)
    render_pdf("flights/_by_group.html.haml")
  end
end
