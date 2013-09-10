class AddExclusionsToAccountingSessions < ActiveRecord::Migration
  def change
    add_column :accounting_sessions, :exclusions, :text, default: nil
  end
end
