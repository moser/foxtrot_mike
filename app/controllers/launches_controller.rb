class LaunchesController < ApplicationController
  def show
    @flight = AbstractFlight.find(params[:flight_id], :include => [:plane, :from, :to, :crew_members])
    render :partial => "launches/show", :locals => { :flight => @flight }, :layout => false if request.xhr?
  end

  def edit
    @flight = AbstractFlight.find(params[:flight_id], :include => [:plane, :from, :to, :crew_members])
    render :partial => "launches/edit", :locals => { :flight => @flight }, :layout => false if request.xhr?
  end

  def create
    r = false
    @flight = AbstractFlight.find(params[:flight_id], :include => [:plane, :from, :to, :crew_members])
    if params["launch_type"] == "nil"
      @flight.launch = nil
      @flight.save
      r = true
    elsif params["launch_type"] == "TowFlight"
      if !@flight.launch.is_a?(TowFlight)
        @flight.launch = TowFlight.new({:abstract_flight => @flight}.merge(params[:launch][:tow_flight]))
        r = @flight.save
      else
        r = @flight.launch.update_attributes(params[:launch][:tow_flight])
      end
    elsif params["launch_type"] == "WireLaunch"
      if !@flight.launch.is_a?(WireLaunch)
        @flight.launch = WireLaunch.new(params[:launch][:wire_launch])
        r = @flight.launch.save && @flight.save
      else
        r = @flight.launch.update_attributes(params[:launch][:wire_launch])
      end
    end

    if r
      #@flight = AbstractFlight.find(params[:flight_id], :include => [:plane, :from, :to, :crew_members])
      render :action => :show
    else
      if request.xhr?
        render :partial => "launches/edit", :locals => { :flight => @flight }, :layout => false, :status => 422
      else
        render :template => "launches/edit", :status => 422
      end
    end
  end
end
