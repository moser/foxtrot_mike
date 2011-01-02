class AddCostHintToFlight < ActiveRecord::Migration
  def self.up
    add_column :abstract_flights, :cost_hint_id, :integer
  end

  def self.down
    remove_column :abstract_flights, :cost_hint_id
  end
end
