class CreateManualCosts < ActiveRecord::Migration
  def self.up
    create_table :manual_costs, :id => false do |t|
      t.string  :id, :limit => 36, :null => false
      t.string :item_id, :limit => 36
      t.string :item_type
      t.integer :value
      t.text :comment
      t.timestamps
    end
    add_index "manual_costs", ["id"], :name => "index_manual_costs_on_id", :unique => true
  end

  def self.down
    drop_table :manual_costs
  end
end
