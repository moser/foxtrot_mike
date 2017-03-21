class PlaneStatisticsController < ApplicationController
  def index
    @groups = Group.all
    group_id = params[:group_id]
    @year = (params[:year] or 1.year.ago.year).to_i

    @planes = []
    if not group_id.nil?
      @group = Group.find(group_id)
      @planes = @group.planes
      res = ActiveRecord::Base.connection.execute(
        "SELECT plane_id, cost_hint_id, count(1) as cnt, sum(arrival_i - departure_i) as duration, count(distinct seat1_person_id) as pilot_count
         FROM abstract_flights
         WHERE departure_date BETWEEN '#{@year}-01-01' AND '#{@year}-12-31'
         GROUP BY plane_id, cost_hint_id"
      )
      @stats = res.group_by { |row| row['plane_id'] }
      res = ActiveRecord::Base.connection.execute(
        "SELECT plane_id, count(distinct seat1_person_id) as pilot_count
         FROM abstract_flights
         WHERE departure_date BETWEEN '#{@year}-01-01' AND '#{@year}-12-31'
         GROUP BY plane_id"
      )
      @pilot_stats = Hash[res.map { |row| [row['plane_id'], row['pilot_count']] }]
      @cost_hints = Hash[CostHint.all.map {|ch| [ch.id.to_s, ch]}]
    end
  end
end
