class AddDateToAccountingSessions < ActiveRecord::Migration
  def self.up
    add_column :accounting_sessions, :end_date, :date
  end

  def self.down
    remove_column :accounting_sessions, :end_date
  end
end
