class CreateAirfields < ActiveRecord::Migration
  def self.up
    create_table :airfields do |t|
      t.string :name
      t.string :registration

      t.timestamps
    end
  end

  def self.down
    drop_table :airfields
  end
end
