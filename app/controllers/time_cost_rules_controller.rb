class TimeCostRulesController < ApplicationController
  #before_filter :login_required

  def index
    if @after.nil?
      @time_cost_rules = TimeCostRule.find(:all)
    else
      @time_cost_rules = TimeCostRule.find(:all, :conditions => ['updated_at > ?', @after] )
    end

    respond_to do |format|
      format.html # index.haml
      format.json  { render :json => @time_cost_rules.to_json }
    end
  end
end
