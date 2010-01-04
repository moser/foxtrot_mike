class MakeFlightsRevisable < ActiveRecord::Migration
  def self.up
        add_column :flights, :revisable_original_id, :string, :limit => 36
        add_column :flights, :revisable_branched_from_id, :string, :limit => 36
        add_column :flights, :revisable_number, :integer, :default => 0
        add_column :flights, :revisable_name, :string
        add_column :flights, :revisable_type, :string
        add_column :flights, :revisable_current_at, :datetime
        add_column :flights, :revisable_revised_at, :datetime
        add_column :flights, :revisable_deleted_at, :datetime
        add_column :flights, :revisable_is_current, :boolean, :default => true
      end

  def self.down
        remove_column :flights, :revisable_original_id
        remove_column :flights, :revisable_branched_from_id
        remove_column :flights, :revisable_number
        remove_column :flights, :revisable_name
        remove_column :flights, :revisable_type
        remove_column :flights, :revisable_current_at
        remove_column :flights, :revisable_revised_at
        remove_column :flights, :revisable_deleted_at
        remove_column :flights, :revisable_is_current
      end
end
