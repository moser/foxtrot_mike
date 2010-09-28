class TimelinesController < ApplicationController
  include TimelineStuff
  def show
    stylesheet :timeline
    if params[:plane_id]
      setup_vars(Flight.includes(:plane, :from, :to, :crew_members).where(:plane_id => params[:plane_id]))
      render :partial => "common/timeline", :locals => timeline_locals([Plane.find(params[:plane_id]), :timeline])
    elsif params[:license_id]
      license = License.find(params[:license_id])
      setup_vars(license.flights)
      render :partial => "common/timeline", :locals => timeline_locals([license, :timeline])
    end
  end
end
