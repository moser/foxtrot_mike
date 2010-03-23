class CreateCrews < ActiveRecord::Migration
  def self.up
    create_table :crews, :id => false do |t|
      t.string    :id,              :limit => 36
      t.string    :flight_id,        :limit => 36
      t.string    :seat1_id,        :limit => 36
      t.string    :seat2_id,        :limit => 36
      t.integer   :passengers
      t.string    :type
      t.timestamps
    end
    add_index "crews", ["id"], :name => "index_crews_on_id", :unique => true
  end

  def self.down
    drop_table :crews
  end
end
