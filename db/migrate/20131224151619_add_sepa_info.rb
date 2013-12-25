class AddSepaInfo < ActiveRecord::Migration
  def change
    add_column :financial_accounts, :iban, :string
    add_column :financial_accounts, :bic, :string

    add_column :financial_accounts, :mandate_id, :string
    add_column :financial_accounts, :mandate_date_of_signature, :date
    add_column :financial_accounts, :first_debit_accounting_session_id, :integer, default: nil

    add_column :financial_accounts, :creditor_identifier, :string

    add_column :accounting_sessions, :debit_type, :string, default: 'dta'
  end
end
