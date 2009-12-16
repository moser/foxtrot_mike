class AddCcToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :person_cost_category_id, :integer
  end

  def self.down
    remove_column :people, :person_cost_category_id
  end
end
