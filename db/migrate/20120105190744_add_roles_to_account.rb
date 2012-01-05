class AddRolesToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :admin, :boolean, :default => false
    add_column :accounts, :license_official, :boolean, :default => false
    add_column :accounts, :treasurer, :boolean, :default => false
    add_column :accounts, :controller, :boolean, :default => false
    add_column :accounts, :reader, :boolean, :default => false
  end
end
