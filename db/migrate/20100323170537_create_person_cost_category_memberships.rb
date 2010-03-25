class CreatePersonCostCategoryMemberships < ActiveRecord::Migration
  def self.up
    create_table :person_cost_category_memberships do |t|
      t.string :person_id
      t.integer :person_cost_category_id
      t.datetime :from
      t.datetime :to
      t.timestamps
    end
  end

  def self.down
    drop_table :person_cost_category_memberships
  end
end
