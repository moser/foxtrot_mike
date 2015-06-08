class WireLauncherLogBooksController < ApplicationController
  nested :wire_launcher

  def show
    wire_launcher = find_nested
    authorize! :read, wire_launcher

    @from = params[:from] || 30.days.ago.to_date
    @to = params[:to] || 0.days.ago.to_date

    @counts = wire_launcher.wire_launches.between(@from, @to).group_by do |wire_launch|
      wire_launch.operator
    end.map do |person, launches|
      [person, launches.count]
    end.sort_by do |person, launches|
      launches
    end.reverse
  end
end
