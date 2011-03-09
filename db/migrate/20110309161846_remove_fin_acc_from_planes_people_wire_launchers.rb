class RemoveFinAccFromPlanesPeopleWireLaunchers < ActiveRecord::Migration
  def self.up
    remove_column :planes, :financial_account_id
    remove_column :people, :financial_account_id
    remove_column :wire_launchers, :financial_account_id
  end

  def self.down
    add_column :planes, :financial_account_id, :integer
    add_column :people, :financial_account_id, :integer
    add_column :wire_launchers, :financial_account_id, :integer
  end
end
