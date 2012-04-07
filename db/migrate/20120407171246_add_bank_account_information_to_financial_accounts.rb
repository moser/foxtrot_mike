class AddBankAccountInformationToFinancialAccounts < ActiveRecord::Migration
  def change
    add_column :financial_accounts, :bank_account_holder, :string, :default => ""
    add_column :financial_accounts, :bank_account_number, :string, :default => ""
    add_column :financial_accounts, :bank_code, :string, :default => ""
  end
end
