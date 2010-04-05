class TimeCostRulesController < ApplicationController
  #before_filter :login_required

  def index
    conditions = []
    unless @after.nil?
      conditions = ['updated_at > ?', @after]
    end
    if params[:person_cost_category_id] && params[:plane_cost_category_id]
      conditions = { :person_cost_category_id => params[:person_cost_category_id],
                     :plane_cost_category_id => params[:plane_cost_category_id] }
    end
    @time_cost_rules = TimeCostRule.find(:all, :conditions => conditions)
    now = Time.zone.now #TODO booking now
    @not_valid_anymore = @time_cost_rules.find_all { |r| r.not_valid_anymore_at?(now) }.sort_by { |r| r.valid_to }
    @valid = @time_cost_rules.find_all { |r| r.valid_at?(now) }.sort_by { |r| r.valid_to || 1000.years.from_now }
    @not_yet_valid = @time_cost_rules.find_all { |r| r.not_yet_valid_at?(now) }.sort_by { |r| r.valid_from }
    respond_to do |format|
      format.html do
        if request.xhr?
          render :layout => false
        end
      end
      format.json  { render :json => @time_cost_rules.to_json }
    end
  end
end
