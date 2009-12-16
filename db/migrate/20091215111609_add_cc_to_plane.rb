class AddCcToPlane < ActiveRecord::Migration
  def self.up
    add_column :planes, :plane_cost_category_id, :integer
  end

  def self.down
    remove_column :planes, :plane_cost_category_id
  end
end
