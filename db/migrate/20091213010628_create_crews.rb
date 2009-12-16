class CreateCrews < ActiveRecord::Migration
  def self.up
    create_table :crews do |t|
      t.references :pic
      t.references :co
      t.references :trainee
      t.references :instructor
      t.integer    :passengers
      t.string :type
      t.timestamps
    end
  end

  def self.down
    drop_table :crews
  end
end
