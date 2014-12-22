class BlsvStatisticsController < ApplicationController
  def new
    authorize! :read, Person
    @groups = Group.all
  end

  def create
    authorize! :read, Person
    @date = params[:stat][:day]
    @group = Group.find(params[:group_id])
    @statistics = BlsvStatistics.new(@group, @date)
  end
end
