class WireLauncherCostCategoryMembershipsController < ApplicationController
  #before_filter :login_required
  
  def index
    if @after.nil?
      @wire_launcher_cost_category_memberships = WireLauncherCostCategoryMembership.find(:all)
    else
      @wire_launcher_cost_category_memberships = WireLauncherCostCategoryMembership.find(:all, :conditions => ['updated_at > ?', @after] )
    end

    respond_to do |format|
      format.json  { render :json => @wire_launcher_cost_category_memberships }
    end
  end
end
