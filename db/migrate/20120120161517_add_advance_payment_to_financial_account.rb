class AddAdvancePaymentToFinancialAccount < ActiveRecord::Migration
  def change
    add_column :financial_accounts, :advance_payment, :boolean, :default => false
  end
end
