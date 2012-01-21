class AddManualToAccountingEntry < ActiveRecord::Migration
  def change
    add_column :accounting_entries, :manual, :boolean, :default => false
  end
end
