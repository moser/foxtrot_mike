class CreatePersonCostCategoryMemberships < ActiveRecord::Migration
  def self.up
    create_table :person_cost_category_memberships do |t|
      t.string :person_id, :limit => 36
      t.integer :person_cost_category_id
      t.date :valid_from, :valid_to
      t.timestamps
    end
  end

  def self.down
    drop_table :person_cost_category_memberships
  end
end
