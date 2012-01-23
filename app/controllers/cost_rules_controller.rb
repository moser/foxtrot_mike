class CostRulesController < ApplicationController
  javascript :cost_rules, :timepicker, :lala
  stylesheet :cost_rules
  COST_RULE_TYPES = { PlaneCostCategory => FlightCostRule, WireLauncherCostCategory => WireLaunchCostRule }

  def index
    @person_cost_categories = PersonCostCategory.all
    @plane_cost_categories = PlaneCostCategory.all
    @wire_launcher_cost_categories = WireLauncherCostCategory.all

    #params[:cost_rule_type] || "time_cost_rules"

    @current_person_cost_category = PersonCostCategory.find(params[:person_cost_category_id]) if params[:person_cost_category_id]
    @current_other_cost_category = PlaneCostCategory.find(params[:plane_cost_category_id]) if params[:plane_cost_category_id]
    @current_other_cost_category = WireLauncherCostCategory.find(params[:wire_launcher_cost_category_id]) if params[:wire_launcher_cost_category_id]

    @current_person_cost_category ||= @person_cost_categories.first
    @current_other_cost_category ||= @plane_cost_categories.first

    @current_cost_rule_klass = COST_RULE_TYPES[@current_other_cost_category.class]

    if @current_person_cost_category && @current_other_cost_category && @current_cost_rule_klass
      @cost_rules = @current_cost_rule_klass.where(:person_cost_category_id => @current_person_cost_category.id,
                                                        :"#{@current_other_cost_category.class.name.underscore}_id" => @current_other_cost_category.id)
      @not_valid_anymore = @cost_rules.select { |r| r.outdated? }.sort_by { |r| r.valid_to }
      @valid = @cost_rules.select { |r| r.in_effect? }.sort_by { |r| r.valid_to || 1000.years.from_now.to_date }
      @not_yet_valid = @cost_rules.select { |r| r.not_yet_in_effect? }.sort_by { |r| r.valid_from }
    end
  end

private
  def now
    @now ||= AccountingSession.latest_session_end
  end
end
