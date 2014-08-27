class AddDuplicateOf < ActiveRecord::Migration
  def change
    add_column :people, :duplicate_of_id, :string, default: nil
    add_column :people, :deleted, :boolean, default: false
    add_column :airfields, :duplicate_of_id, :string, default: nil
    add_column :airfields, :deleted, :boolean, default: false
    add_column :planes, :duplicate_of_id, :string, default: nil
    add_column :planes, :deleted, :boolean, default: false
  end
end
