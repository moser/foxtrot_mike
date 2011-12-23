class AddNumberToFinAcc < ActiveRecord::Migration
  def change
    add_column :financial_accounts, :number, :string, :default => ""
  end
end
