class CreateTowLevels < ActiveRecord::Migration
  def self.up
    create_table :tow_levels do |t|
      t.string :name
      t.integer :tow_cost_rule_id
      t.integer :cost
      t.string :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :tow_levels
  end
end
