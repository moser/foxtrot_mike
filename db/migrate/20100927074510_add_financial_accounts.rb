class AddFinancialAccounts < ActiveRecord::Migration
  def self.up
    add_column :people, :financial_account_id, :integer
    add_column :planes, :financial_account_id, :integer
    add_column :wire_launchers, :financial_account_id, :integer
  end

  def self.down
    remove_column :people, :financial_account_id
    remove_column :planes, :financial_account_id
    remove_column :wire_launchers, :financial_account_id
  end
end
