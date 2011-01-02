class CreateFlightCostItems < ActiveRecord::Migration
  def self.up
    create_table :flight_cost_items do |t|
      t.integer :value, :additive_value, :financial_account_id
      t.string :depends_on, :name
      t.timestamps
    end
  end

  def self.down
    drop_table :flight_cost_items
  end
end
