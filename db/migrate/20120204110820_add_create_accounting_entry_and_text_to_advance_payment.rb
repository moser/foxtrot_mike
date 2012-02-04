class AddCreateAccountingEntryAndTextToAdvancePayment < ActiveRecord::Migration
  def change
    add_column :advance_payments, :from_id, :integer
    add_column :advance_payments, :text, :string, :default => ""
  end
end
