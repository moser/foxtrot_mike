class AddMaxDebitValueToFinancialAccounts < ActiveRecord::Migration
  def change
    add_column :financial_accounts, :max_debit_value, :integer, default: 100000
  end
end
