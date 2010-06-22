class CreateCrewMembers < ActiveRecord::Migration
  def self.up
    create_table :crew_members, :id => false do |t|
      t.string :id, :limit => 36
      t.string :abstract_flight_id
      t.string :person_id
      t.integer :n
      t.string :type
      t.string :editor_id, :limit => 36
      t.timestamps
    end
    add_index "crew_members", ["id"], :name => "index_crew_members_on_id", :unique => true
  end

  def self.down
    drop_table :crew_members
  end
end
