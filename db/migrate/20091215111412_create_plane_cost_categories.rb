class CreatePlaneCostCategories < ActiveRecord::Migration
  def self.up
    create_table :plane_cost_categories do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :plane_cost_categories
  end
end
