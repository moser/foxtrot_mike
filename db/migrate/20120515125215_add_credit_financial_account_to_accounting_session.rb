class AddCreditFinancialAccountToAccountingSession < ActiveRecord::Migration
  def change
    add_column :accounting_sessions, :credit_financial_account_id, :integer
  end
end
