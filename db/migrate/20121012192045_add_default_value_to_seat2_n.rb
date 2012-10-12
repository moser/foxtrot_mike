class AddDefaultValueToSeat2N < ActiveRecord::Migration
  def change
    remove_column :abstract_flights, :seat2_n
    add_column :abstract_flights, :seat2_n, :integer, default: 0
  end
end
