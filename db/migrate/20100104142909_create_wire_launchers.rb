class CreateWireLaunchers < ActiveRecord::Migration
  def self.up
    create_table :wire_launchers, :id => false do |t|
      t.string :id, :limit => 36
      t.string :registration

      t.timestamps
    end
    add_index "wire_launchers", ["id"], :name => "index_wire_launchers_on_id", :unique => true
  end

  def self.down
    drop_table :wire_launchers
  end
end
