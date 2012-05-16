class AddBankDebitToAccountingSessions < ActiveRecord::Migration
  def change
    add_column :accounting_sessions, :bank_debit, :boolean, :default => false
  end
end
