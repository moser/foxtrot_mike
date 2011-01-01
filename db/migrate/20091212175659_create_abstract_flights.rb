class CreateAbstractFlights < ActiveRecord::Migration
  def self.up
    create_table :abstract_flights, :id => false do |t|
      t.string      :id,           :limit => 36
      t.string      :plane_id,     :limit => 36
      t.string      :from_id,      :limit => 36
      t.string      :to_id,        :limit => 36
      t.string      :controller_id,:limit => 36
      t.string      :launch_id,    :limit => 36 #nil || wire_launch.id || abstract_flight.id
      t.string      :launch_type
      t.datetime    :departure
      t.integer     :duration, :engine_duration
      t.text        :comment
      
      t.string      :type
      t.timestamps
    end
    add_index "abstract_flights", ["id"], :name => "index_abstract_flights_on_id", :unique => true
  end

  def self.down
    drop_table :abstract_flights
  end
end
