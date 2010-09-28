class CreatePlaneCostCategoryMemberships < ActiveRecord::Migration
  def self.up
    create_table :plane_cost_category_memberships do |t|
      t.string :plane_id, :limit => 36
      t.integer :plane_cost_category_id
      t.date :valid_from, :valid_to
      t.timestamps
    end
  end

  def self.down
    drop_table :plane_cost_category_memberships
  end
end
