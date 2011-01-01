class CreateAccountRoles < ActiveRecord::Migration
  def self.up
    create_table :account_roles do |t|
      t.integer :account_id 
      t.string :role
      t.timestamps
    end
  end

  def self.down
    drop_table :account_roles
  end
end
