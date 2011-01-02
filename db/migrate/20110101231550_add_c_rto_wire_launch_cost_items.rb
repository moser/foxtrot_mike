class AddCRtoWireLaunchCostItems < ActiveRecord::Migration
  def self.up
    add_column :wire_launch_cost_items, :wire_launch_cost_rule_id, :integer
  end

  def self.down
    remove_column :wire_launch_cost_items, :wire_launch_cost_rule_id
  end
end
