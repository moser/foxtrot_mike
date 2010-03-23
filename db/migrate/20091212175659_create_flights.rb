class CreateFlights < ActiveRecord::Migration
  def self.up
    create_table :flights, :id => false do |t|
      t.string      :id,        :limit => 36
      t.string      :plane_id,        :limit => 36
      t.string      :from_id,        :limit => 36
      t.string      :to_id,        :limit => 36
      t.datetime    :departure
      t.integer     :duration
      t.string      :purpose
      t.text        :comment
      t.timestamps
    end
    add_index "flights", ["id"], :name => "index_flights_on_id", :unique => true
  end

  def self.down
    drop_table :flights
  end
end
