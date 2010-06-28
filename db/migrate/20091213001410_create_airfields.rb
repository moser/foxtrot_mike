class CreateAirfields < ActiveRecord::Migration
  def self.up
    create_table :airfields, :id => false do |t|
      t.string :id, :limit => 36
      t.string :name
      t.string :registration
      t.boolean   :disabled, :default => false
      t.timestamps
    end
    add_index "airfields", ["id"], :name => "index_airfields_on_id", :unique => true
  end

  def self.down
    drop_table :airfields
  end
end
