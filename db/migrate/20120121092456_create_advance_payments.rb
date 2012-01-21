class CreateAdvancePayments < ActiveRecord::Migration
  def change
    create_table :advance_payments do |t|
      t.date :date
      t.integer :financial_account_id
      t.integer :value
      t.timestamps
    end
  end
end
