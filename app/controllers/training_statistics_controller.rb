class TrainingStatisticsController < ApplicationController
  def new
    authorize! :read, AbstractFlight
    @legal_plane_classes = LegalPlaneClass.all
  end

  def create
    authorize! :read, AbstractFlight
    @year = params[:year]
    @legal_plane_class = LegalPlaneClass.find(params[:legal_plane_class_id])
    from = Date.parse("#{@year}-01-01")
    to = Date.parse("#{@year}-12-31")
    @training_statistic = TrainingStatistics.new(Flight.where('departure_date >= ?', from).where('departure_date <= ?', to), @legal_plane_class)
  end
end
