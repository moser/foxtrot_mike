class AddTextToAccountingEntry < ActiveRecord::Migration
  def change
    add_column :accounting_entries, :text, :string
  end
end
