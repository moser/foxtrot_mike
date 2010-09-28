class CreateLicenses < ActiveRecord::Migration
  def self.up
    create_table :licenses do |t|
      t.string :name
      t.string :level, :null => false, :default => "normal"
      t.date :valid_from,:valid_to
      t.string :person_id, :limit => 36      

      t.timestamps
    end
  end

  def self.down
    drop_table :licenses
  end
end
