class CreatePlanes < ActiveRecord::Migration
  def self.up
    create_table :planes, :id => false do |t|
      t.string :id, :limit => 36
      t.string :registration
      t.string :make
      t.string :competition_sign
      t.string :editor_id, :limit => 36
      t.integer :plane_cost_category_id
      
      t.timestamps
    end
    add_index "planes", ["id"], :name => "index_planes_on_id", :unique => true
  end

  def self.down
    drop_table :planes
  end
end
