class TowCostRulesController < ApplicationController
  #before_filter :login_required

  def index
    if @after.nil?
      @tow_cost_rules = TowCostRule.find(:all)
    else
      @tow_cost_rules = TowCostRule.find(:all, :conditions => ['updated_at > ?', @after] )
    end

    respond_to do |format|
      format.html # index.haml
      format.json  { render :json => @tow_cost_rules.to_json }
    end
  end
end
