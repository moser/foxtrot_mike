class MakeAirfieldsRevisable < ActiveRecord::Migration
  def self.up
    add_column :airfields, :revisable_original_id, :string, :limit => 36
    add_column :airfields, :revisable_branched_from_id, :string, :limit => 36
    add_column :airfields, :revisable_number, :integer, :default => 0
    add_column :airfields, :revisable_name, :string
    add_column :airfields, :revisable_type, :string
    add_column :airfields, :revisable_current_at, :datetime
    add_column :airfields, :revisable_revised_at, :datetime
    add_column :airfields, :revisable_deleted_at, :datetime
    add_column :airfields, :revisable_is_current, :boolean, :default => 1
  end

  def self.down
    remove_column :airfields, :revisable_original_id
    remove_column :airfields, :revisable_branched_from_id
    remove_column :airfields, :revisable_number
    remove_column :airfields, :revisable_name
    remove_column :airfields, :revisable_type
    remove_column :airfields, :revisable_current_at
    remove_column :airfields, :revisable_revised_at
    remove_column :airfields, :revisable_deleted_at
    remove_column :airfields, :revisable_is_current
  end
end
