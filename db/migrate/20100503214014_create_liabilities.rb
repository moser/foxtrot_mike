class CreateLiabilities < ActiveRecord::Migration
  def self.up
    create_table :liabilities, :id => false do |t|
      t.string :id
      t.string :flight_id
      t.string :person_id
      t.datetime :booked_at
      t.integer :proportion
      t.string :editor_id, :limit => 36
      t.timestamps
    end
  end

  def self.down
    drop_table :liabilities
  end
end
