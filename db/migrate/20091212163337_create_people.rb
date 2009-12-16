class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table "people" do |t|
      t.string    :lastname
      t.string    :firstname
      t.datetime  :birthdate
      t.string    :email
      
      t.timestamps
    end
  end

  def self.down
    drop_table "people"
  end
end
