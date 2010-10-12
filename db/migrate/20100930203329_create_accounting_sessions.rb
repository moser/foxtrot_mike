class CreateAccountingSessions < ActiveRecord::Migration
  def self.up
    create_table :accounting_sessions do |t|
      t.string :name
      t.datetime :finished_at

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_sessions
  end
end
