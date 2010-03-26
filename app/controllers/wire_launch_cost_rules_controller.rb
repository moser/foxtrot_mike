class WireLaunchCostRulesController < ApplicationController
  #before_filter :login_required

  def index
    if @after.nil?
      @wire_launch_cost_rules = WireLaunchCostRule.find(:all)
    else
      @wire_launch_cost_rules = WireLaunchCostRule.find(:all, :conditions => ['updated_at > ?', @after] )
    end

    respond_to do |format|
      format.html # index.haml
      format.json  { render :json => @wire_launch_cost_rules.to_json }
    end
  end
end
