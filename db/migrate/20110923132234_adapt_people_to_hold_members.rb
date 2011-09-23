class AdaptPeopleToHoldMembers < ActiveRecord::Migration
  def change
    remove_column :people, :type
    remove_column :people, :fibunr
    remove_column :people, :description
    rename_column :people, :ssv_member_state, :member_state
  end
end
