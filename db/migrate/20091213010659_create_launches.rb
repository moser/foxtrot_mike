class CreateLaunches < ActiveRecord::Migration
  def self.up
    create_table :launches do |t|
      t.references :tow_flight
      t.references :wire_launcher
      
      t.string :type
      t.timestamps
    end
  end

  def self.down
    drop_table :launches
  end
end
