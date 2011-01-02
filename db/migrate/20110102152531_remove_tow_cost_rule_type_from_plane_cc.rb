class RemoveTowCostRuleTypeFromPlaneCc < ActiveRecord::Migration
  def self.down
    remove_column :plane_cost_categories, :tow_cost_rule_type
  end

  def self.down
    add_column :plane_cost_categories, :tow_cost_rule_type, :string
  end
end
