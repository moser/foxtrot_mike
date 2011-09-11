class AddSeatCountToPlane < ActiveRecord::Migration
  def change
    add_column :planes, :seat_count, :integer
  end
end
