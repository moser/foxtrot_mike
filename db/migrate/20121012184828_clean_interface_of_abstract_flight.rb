class CleanInterfaceOfAbstractFlight < ActiveRecord::Migration
  def up
    drop_table :crew_members
    add_column :abstract_flights, :seat1_person_id, :string 
    add_column :abstract_flights, :seat2_person_id, :string 
    add_column :abstract_flights, :seat2_n, :integer
  end

  def down
    raise "Impossibru"
  end
end
