class CreateFlightCostRules < ActiveRecord::Migration
  def self.up
    create_table :flight_cost_rules do |t|
      t.string :name, :flight_type
      t.integer :plane_cost_category_id, :person_cost_category_id
      t.date :valid_from, :valid_to
      t.text :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :flight_cost_rules
  end
end
