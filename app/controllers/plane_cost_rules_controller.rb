class PlaneCostRulesController < ApplicationController
  def index
    @person_cost_categories = PersonCostCategory.all
    @plane_cost_categories = PlaneCostCategory.all
  end
end
