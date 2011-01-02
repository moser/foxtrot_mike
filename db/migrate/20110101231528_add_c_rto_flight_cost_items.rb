class AddCRtoFlightCostItems < ActiveRecord::Migration
  def self.up
    add_column :flight_cost_items, :flight_cost_rule_id, :integer
  end

  def self.down
    remove_column :flight_cost_items, :flight_cost_rule_id
  end
end
