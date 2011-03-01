class AddStartDateToAccountingSessions < ActiveRecord::Migration
  def self.up
    add_column :accounting_sessions, :start_date, :date
  end

  def self.down
    remove_column :accounting_sessions, :start_date
  end
end
