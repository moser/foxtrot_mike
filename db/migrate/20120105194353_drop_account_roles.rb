class DropAccountRoles < ActiveRecord::Migration
  def self.down
    create_table :account_roles do |t|
      t.integer :account_id 
      t.string :role
      t.timestamps
    end
  end

  def self.up
    drop_table :account_roles
  end
end
