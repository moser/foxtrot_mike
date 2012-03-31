class AddAccoountingDateToAccountingSession < ActiveRecord::Migration
  def change
    add_column :accounting_sessions, :accounting_date, :date
  end
end
