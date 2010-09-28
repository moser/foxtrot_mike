class PlaneCostRulesController < ApplicationController
  javascript :plane_cost_rules, :timepicker
  stylesheet :plane_cost_rules

  def index
    @person_cost_categories = PersonCostCategory.all
    @plane_cost_categories = PlaneCostCategory.all

    @current_person_cost_category = PersonCostCategory.find(params[:person_cost_category_id]) if params[:person_cost_category_id]
    @current_plane_cost_category = PlaneCostCategory.find(params[:plane_cost_category_id]) if params[:plane_cost_category_id]
    @current_cost_rule_type = params[:cost_rule_type] || "time_cost_rules"

    @current_person_cost_category ||= @person_cost_categories.first
    @current_plane_cost_category ||= @plane_cost_categories.first

    if @current_person_cost_category && @current_plane_cost_category && @current_cost_rule_type
      klass = @current_cost_rule_type.singularize.camelize.constantize
      @cost_rules = klass.where(:person_cost_category_id => @current_person_cost_category.id,
                                   :plane_cost_category_id => @current_plane_cost_category.id)
      @not_valid_anymore = @cost_rules.select { |r| r.not_valid_anymore_at? }
      @valid = @cost_rules.select { |r| r.valid_at? }
      @not_yet_valid = @cost_rules.select { |r| r.not_yet_valid_at? }
    end
  end
end
