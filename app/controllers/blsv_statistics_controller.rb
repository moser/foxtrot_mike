class BlsvStatisticsController < ApplicationController
  def new
    authorize! :read, Person
    @groups = Group.all
  end

  def create
    authorize! :read, Person
    @date = Date.new(params[:stat]['day(1i)'].to_i, params[:stat]['day(2i)'].to_i, params[:stat]['day(3i)'].to_i)
    @group = Group.find(params[:group_id])
    @statistics = BlsvStatistics.new(@group, @date)
  end
end
