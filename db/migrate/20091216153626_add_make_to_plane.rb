class AddMakeToPlane < ActiveRecord::Migration
  def self.up
    add_column :planes, :make, :string
  end

  def self.down
    remove_column :planes, :make
  end
end
