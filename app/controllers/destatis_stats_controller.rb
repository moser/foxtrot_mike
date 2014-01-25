class DestatisStatsController < ApplicationController
  def new
    authorize! :read, Flight
    @airfields = Airfield.all
  end

  def create
    authorize! :read, Flight
    @year = params[:year]
    @airfield = Airfield.find(params[:airfield_id])
    from = Date.parse("#{@year}-01-01")
    to = Date.parse("#{@year}-12-31")
    @destatis_stats = DestatisAirtrafficStats.new(AbstractFlight.where('departure_date >= ?', from).where('departure_date <= ?', to), @airfield)
  end
end
