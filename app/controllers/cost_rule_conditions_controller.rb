class CostRuleConditionsController < ResourceController
  nested :cost_rule

  def types
    @types ||= [ CostHintCondition, NumberCostRuleCondition ].map { |e| e.to_s }
  end

  def nested_id
    params[:flight_cost_rule_id] || params[:wire_launch_cost_rule_id]
  end

  def find_nested
    if params[:flight_cost_rule_id]
      @nested = @cost_rule = FlightCostRule.find(nested_id)
    elsif params[:wire_launch_cost_rule_id]
      @nested = @cost_rule = WireLaunchCostRule.find(nested_id)
    end
  end

  def create
    if types.include?(params[:cost_rule_condition_type])
      p params[:cost_rule_condition][params[:cost_rule_condition_type].underscore]
      @cost_rule_condition = params[:cost_rule_condition_type].constantize.new(params[:cost_rule_condition][params[:cost_rule_condition_type].underscore])
      authorize! :create, @cost_rule_condition
      if nested && nested_id
        @cost_rule_condition.cost_rule = find_nested
      end
      if @cost_rule_condition.save
        redirect_to([@cost_rule_condition.cost_rule, CostRuleCondition])
      else
        p @cost_rule_condition.errors
        @cost_rule_condition_type = params[:cost_rule_condition_type]
        render :action => :new, :layout => !request.xhr?, :status => 422
      end
    else
      render :text => "", :status => 404
    end
  end

  def update
    @cost_rule_condition = CostRuleCondition.find(params[:id])
    if @cost_rule_condition.update_attributes(params[@cost_rule_condition.class.name.underscore])
      redirect_to([@cost_rule_condition.cost_rule, CostRuleCondition])
    else
      render :action => :edit, :layout => !request.xhr?, :status => 422
    end
  end
end
