class CreateWireLauncherCostCategoryMemberships < ActiveRecord::Migration
  def self.up
    create_table :wire_launcher_cost_category_memberships do |t|
      t.string :wire_launcher_id, :limit => 36
      t.integer :wire_launcher_cost_category_id
      t.datetime :valid_from, :valid_to
      t.timestamps
    end
  end

  def self.down
    drop_table :wire_launcher_cost_category_memberships
  end
end
