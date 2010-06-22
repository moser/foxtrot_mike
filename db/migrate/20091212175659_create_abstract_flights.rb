class CreateAbstractFlights < ActiveRecord::Migration
  def self.up
    create_table :abstract_flights, :id => false do |t|
      t.string      :id,        :limit => 36
      t.string      :plane_id,        :limit => 36
      t.string      :from_id,        :limit => 36
      t.string      :to_id,        :limit => 36
      t.string      :controller_id,        :limit => 36
      t.datetime    :departure
      t.integer     :duration, :engine_duration
      t.string      :purpose #TODO what purposes are needed, how to save them (enum?)
      t.text        :comment
      t.string      :editor_id, :limit => 36
      
      t.string      :type
      #TODO controller_id => person
      t.timestamps
    end
    add_index "abstract_flights", ["id"], :name => "index_abstract_flights_on_id", :unique => true
  end

  def self.down
    drop_table :abstract_flights
  end
end
