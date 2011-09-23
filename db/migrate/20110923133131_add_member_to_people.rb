class AddMemberToPeople < ActiveRecord::Migration
  def change
    add_column :people, :member, :boolean
  end
end
