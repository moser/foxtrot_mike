class CreateTimeCostRules < ActiveRecord::Migration
  def self.up
    create_table :time_cost_rules do |t|
      t.integer :person_cost_category_id, :plane_cost_category_id, :cost
      t.string :name, :flight_type, :depends_on, :condition_field, :condition_operator, :comment
      t.integer :condition_value, :default => 0
      t.integer :additive_cost, :default => 0
      t.datetime :valid_from, :valid_to
      t.timestamps
    end
  end

  def self.down
    drop_table :time_cost_rules
  end
end
