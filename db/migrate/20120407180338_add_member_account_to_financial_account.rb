class AddMemberAccountToFinancialAccount < ActiveRecord::Migration
  def change
    add_column :financial_accounts, :member_account, :boolean, :default => false
  end
end
