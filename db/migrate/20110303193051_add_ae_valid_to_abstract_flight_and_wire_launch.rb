class AddAeValidToAbstractFlightAndWireLaunch < ActiveRecord::Migration
  def self.up
    add_column :abstract_flights, :accounting_entries_valid, :boolean, :default => false
    add_column :wire_launches, :accounting_entries_valid, :boolean, :default => false
  end

  def self.down
    remove_column :abstract_flights, :accounting_entries_valid
    remove_column :wire_launches, :accounting_entries_valid
  end
end
