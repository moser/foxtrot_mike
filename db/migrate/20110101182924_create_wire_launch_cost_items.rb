class CreateWireLaunchCostItems < ActiveRecord::Migration
  def self.up
    create_table :wire_launch_cost_items do |t|
      t.string :name
      t.integer :value, :financial_account_id
      t.timestamps
    end
  end

  def self.down
    drop_table :wire_launch_cost_items
  end
end
