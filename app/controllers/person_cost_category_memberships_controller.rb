class PersonCostCategoryMembershipsController < ApplicationController
  #before_filter :login_required
  
  def index
    if @after.nil?
      @person_cost_category_memberships = PersonCostCategoryMembership.find(:all)
    else
      @person_cost_category_memberships = PersonCostCategoryMembership.find(:all, :conditions => ['updated_at > ?', @after] )
    end

    respond_to do |format|
      format.json  { render :json => @person_cost_category_memberships }
    end
  end
end
