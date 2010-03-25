class CreateTowCostRules < ActiveRecord::Migration
  def self.up
    create_table :tow_cost_rules do |t|
      t.integer :person_cost_category_id, :plane_cost_category_id, :cost
      t.string :name, :level
      t.timestamps
    end
  end

  def self.down
    drop_table :tow_cost_rules
  end
end
