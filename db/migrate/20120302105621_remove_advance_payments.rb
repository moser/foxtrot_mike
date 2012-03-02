class RemoveAdvancePayments < ActiveRecord::Migration
  def up
    drop_table :advance_payments
  end

  def down
    create_table "advance_payments" do |t|
      t.date     "date"
      t.integer  "financial_account_id"
      t.integer  "value"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "from_id"
      t.string   "text", :default => ""
    end
  end
end
