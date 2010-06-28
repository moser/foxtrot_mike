class CreatePlaneCostCategories < ActiveRecord::Migration
  def self.up
    create_table :plane_cost_categories do |t|
      t.string :name
      t.string :tow_cost_rule_type #TowCostRule|TimeCostRule
      t.timestamps
    end
  end

  def self.down
    drop_table :plane_cost_categories
  end
end
