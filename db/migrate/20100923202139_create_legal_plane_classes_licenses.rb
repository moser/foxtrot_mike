class CreateLegalPlaneClassesLicenses < ActiveRecord::Migration
  def self.up
    create_table :legal_plane_classes_licenses, :id => false do |t|
      t.integer :legal_plane_class_id, :license_id
    end
  end

  def self.down
    drop_table :legal_plane_classes_licenses
  end
end
