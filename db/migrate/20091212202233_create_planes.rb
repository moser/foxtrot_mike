class CreatePlanes < ActiveRecord::Migration
  def self.up
    create_table :planes do |t|
      t.string :registration
      t.string :type
      
      t.timestamps
    end
  end

  def self.down
    drop_table :planes
  end
end
