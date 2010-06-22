class WireLaunchersController < ApplicationController
  def index
    if @after.nil?
      @wire_launchers = WireLauncher.find(:all)
    else
      @wire_launchers = WireLauncher.find(:all, :conditions => ['updated_at > ?', @after] )
    end 
    
    respond_to do |format|
      format.html # index.haml
      format.json  { render :json => @wire_launchers.to_json(:only => WireLauncher.shared_attribute_names) }
    end
  end
  
  #TODO create
end
