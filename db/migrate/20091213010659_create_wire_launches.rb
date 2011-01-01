class CreateWireLaunches < ActiveRecord::Migration
  def self.up
    create_table :wire_launches, :id => false do |t|
      t.string :id,               :limit => 36
      t.string :wire_launcher_id, :limit => 36
      t.timestamps
    end
    add_index "wire_launches", ["id"], :name => "index_wire_launches_on_id", :unique => true
  end

  def self.down
    drop_table :wire_launches
  end
end
