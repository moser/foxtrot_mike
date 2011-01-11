class AddAccountingSessionIdToAbstractFlights < ActiveRecord::Migration
  def self.up
    add_column :abstract_flights, :accounting_session_id, :integer
  end

  def self.down
    remove_column :abstract_flights, :accounting_session_id
  end
end
