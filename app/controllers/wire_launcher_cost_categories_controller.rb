class WireLauncherCostCategoriesController < ApplicationController
  #before_filter :login_required
  
  def index
    if @after.nil?
      @wire_launcher_cost_categories = WireLauncherCostCategory.find(:all)
    else
      @wire_launcher_cost_categories = WireLauncherCostCategory.find(:all, :conditions => ['updated_at > ?', @after] )
    end

    respond_to do |format|
      format.html # index.haml
      format.json  { render :json => @wire_launcher_cost_categories }
    end
  end
end
