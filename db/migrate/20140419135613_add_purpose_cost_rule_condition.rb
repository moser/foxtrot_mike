class AddPurposeCostRuleCondition < ActiveRecord::Migration
  def change
    add_column :cost_rule_conditions, :purpose_filter, :string
  end
end
