class MakePlanesRevisable < ActiveRecord::Migration
  def self.up
        add_column :planes, :revisable_original_id, :integer
        add_column :planes, :revisable_branched_from_id, :integer
        add_column :planes, :revisable_number, :integer, :default => 0
        add_column :planes, :revisable_name, :string
        add_column :planes, :revisable_type, :string
        add_column :planes, :revisable_current_at, :datetime
        add_column :planes, :revisable_revised_at, :datetime
        add_column :planes, :revisable_deleted_at, :datetime
        add_column :planes, :revisable_is_current, :boolean, :default => true
      end

  def self.down
        remove_column :planes, :revisable_original_id
        remove_column :planes, :revisable_branched_from_id
        remove_column :planes, :revisable_number
        remove_column :planes, :revisable_name
        remove_column :planes, :revisable_type
        remove_column :planes, :revisable_current_at
        remove_column :planes, :revisable_revised_at
        remove_column :planes, :revisable_deleted_at
        remove_column :planes, :revisable_is_current
      end
end
