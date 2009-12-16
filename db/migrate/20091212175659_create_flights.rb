class CreateFlights < ActiveRecord::Migration
  def self.up
    create_table :flights do |t|
      t.integer :duration
      t.datetime :departure
      t.references :from
      t.references :to
      t.references :plane
      t.references :launch
      t.references :crew
      t.timestamps
    end
  end

  def self.down
    drop_table :flights
  end
end
