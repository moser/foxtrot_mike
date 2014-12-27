class SummariesController < ApplicationController
  def show
    date = params[:date] || Date.today
    flights = AbstractFlight.on(date).group_by(&:plane).map do |plane, flights|
      [plane.registration, flights.count]
    end
    render json: Hash[flights]
  end
end
