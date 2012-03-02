class AddVoucherNumberAndWithoutFlightsToAccountingSession < ActiveRecord::Migration
  def change
    add_column :accounting_sessions, :voucher_number, :string
    add_column :accounting_sessions, :without_flights, :boolean, :default => false
  end
end
