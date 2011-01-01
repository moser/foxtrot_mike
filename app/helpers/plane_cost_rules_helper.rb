module PlaneCostRulesHelper
  def select_cost_parameter_link(text, obj, parameter)
    o = { :person_cost_category_id => @current_person_cost_category.id,
          :"#{@current_other_cost_category.class.name.underscore}_id" => @current_other_cost_category.id,
          :cost_rule_type => @current_cost_rule_type }.merge({ parameter => obj})
    link_to text, cost_rules_path(o), :class => "update_selection", :"data-parameter" => parameter, :"data-value" => obj
  end
end
