class CreateFinancialAccountOwnerships < ActiveRecord::Migration
  def self.up
    create_table :financial_account_ownerships do |t|
      t.string :owner_id, :owner_type
      t.integer :financial_account_id
      t.date :valid_from #this is a time based has_one association, so one date is sufficient.
      t.timestamps
    end
  end

  def self.down
    drop_table :financial_account_ownerships
  end
end
