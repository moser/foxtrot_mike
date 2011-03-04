class RemoveBookedAtFromLiabilities < ActiveRecord::Migration
  def self.up
    remove_column :liabilities, :booked_at
  end

  def self.down
    throw "irreversible"
  end
end
