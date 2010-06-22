class CreatePersonCostCategories < ActiveRecord::Migration
  def self.up
    create_table :person_cost_categories do |t|
      t.string :name
      t.string :editor_id, :limit => 36
      t.timestamps
    end
  end

  def self.down
    drop_table :person_cost_categories
  end
end
