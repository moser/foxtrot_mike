class CreateWireLaunchCostRules < ActiveRecord::Migration
  def self.up
    create_table :wire_launch_cost_rules do |t|
      t.integer :person_cost_category_id, :wire_launcher_cost_category_id, :cost
      t.string :name
      t.date :valid_from, :valid_to
      t.timestamps
    end
  end

  def self.down
    drop_table :wire_launch_cost_rules
  end
end
