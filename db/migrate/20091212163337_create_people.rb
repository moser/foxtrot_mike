class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table "people", :id => false do |t|
      t.string    :id, :limit => 36 #, :null => false
      t.string    :lastname
      t.string    :firstname
      t.datetime  :birthdate
      t.string    :email
      
      t.timestamps
    end
    add_index "people", ["id"], :name => "index_people_on_id", :unique => true
  end

  def self.down
    drop_table "people"
  end
end
