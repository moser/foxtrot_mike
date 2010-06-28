class CreateManualCosts < ActiveRecord::Migration
  def self.up
    create_table :manual_costs do |t|
      t.string :flight_id, :limit => 36
      t.string :launch_id, :limit => 36
      t.integer :value
      t.text :comment
      t.string :type
      t.timestamps
    end
  end

  def self.down
    drop_table :manual_costs
  end
end
