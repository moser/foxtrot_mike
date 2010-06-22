class MakeLaunchesRevisable < ActiveRecord::Migration
  def self.up
        add_column :launches, :revisable_original_id, :integer
        add_column :launches, :revisable_branched_from_id, :integer
        add_column :launches, :revisable_number, :integer, :default => 0
        add_column :launches, :revisable_name, :string
        add_column :launches, :revisable_type, :string
        add_column :launches, :revisable_current_at, :datetime
        add_column :launches, :revisable_revised_at, :datetime
        add_column :launches, :revisable_deleted_at, :datetime
        add_column :launches, :revisable_is_current, :boolean, :default => 1
      end

  def self.down
        remove_column :launches, :revisable_original_id
        remove_column :launches, :revisable_branched_from_id
        remove_column :launches, :revisable_number
        remove_column :launches, :revisable_name
        remove_column :launches, :revisable_type
        remove_column :launches, :revisable_current_at
        remove_column :launches, :revisable_revised_at
        remove_column :launches, :revisable_deleted_at
        remove_column :launches, :revisable_is_current
      end
end
