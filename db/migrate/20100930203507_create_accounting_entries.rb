class CreateAccountingEntries < ActiveRecord::Migration
  def self.up
    create_table :accounting_entries do |t|
      t.integer :from_id
      t.integer :to_id
      t.integer :value
      t.integer :accounting_session_id
      t.string :item_id
      t.string :item_type

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_entries
  end
end
