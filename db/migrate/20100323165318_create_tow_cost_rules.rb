class CreateTowCostRules < ActiveRecord::Migration
  def self.up
    create_table :tow_cost_rules do |t|
      t.integer :person_cost_category_id, :plane_cost_category_id
      t.string :name, :comment
      t.date :valid_from, :valid_to
      t.timestamps
    end
  end

  def self.down
    drop_table :tow_cost_rules
  end
end
