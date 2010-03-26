class PlaneCostCategoryMembershipsController < ApplicationController
  #before_filter :login_required
  
  def index
    if @after.nil?
      @plane_cost_category_memberships = PlaneCostCategoryMembership.find(:all)
    else
      @plane_cost_category_memberships = PlaneCostCategoryMembership.find(:all, :conditions => ['updated_at > ?', @after] )
    end

    respond_to do |format|
      format.json  { render :json => @plane_cost_category_memberships }
    end
  end
end
