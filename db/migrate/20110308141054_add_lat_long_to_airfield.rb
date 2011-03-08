class AddLatLongToAirfield < ActiveRecord::Migration
  def self.up
    add_column :airfields, :lat, :float, :default => 0.0
    add_column :airfields, :long, :float, :default => 0.0
  end

  def self.down
    remove_column :airfields, :lat
    remove_column :airfields, :long
  end
end
