class CreatePlanes < ActiveRecord::Migration
  def self.up
    create_table :planes, :id => false do |t|
      t.string :id, :limit => 36
      t.string :registration, :make, :competition_sign
      t.string :editor_id, :limit => 36
      t.integer :group_id
      #flags... TODO
      t.boolean :has_engine, :can_fly_without_engine, :can_tow, :can_be_towed
      
      t.timestamps
    end
    add_index "planes", ["id"], :name => "index_planes_on_id", :unique => true
  end

  def self.down
    drop_table :planes
  end
end
