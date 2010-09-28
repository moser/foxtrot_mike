class CreateLegalPlaneClasses < ActiveRecord::Migration
  def self.up
    create_table :legal_plane_classes do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :legal_plane_classes
  end
end
