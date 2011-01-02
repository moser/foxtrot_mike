class CreateCostRuleConditions < ActiveRecord::Migration
  def self.up
    create_table :cost_rule_conditions do |t|
      t.integer :cost_rule_id, :cost_hint_id, :condition_value_i
      t.string :condition_field, :condition_operator, :condition_value_s, :cost_rule_type
      t.string :type
      t.timestamps
    end
  end

  def self.down
    drop_table :cost_rule_conditions
  end
end
