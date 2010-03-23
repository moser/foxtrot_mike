class CreateLaunches < ActiveRecord::Migration
  def self.up
    create_table :launches, :id => false do |t|
      t.string :id,        :limit => 36
      t.string :flight_id,        :limit => 36
      t.string :tow_flight_id,        :limit => 36
      t.string :wire_launcher_id,     :limit => 36
      
      t.string :type
      t.timestamps
    end
    add_index "launches", ["id"], :name => "index_launches_on_id", :unique => true
  end

  def self.down
    drop_table :launches
  end
end
