class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table "people", :id => false do |t|
      t.string    :id, :limit => 36 #, :null => false
      t.string    :lastname
      t.string    :firstname
      t.date      :birthdate
      t.string    :title
      t.string    :sex
      t.string    :address1
      t.string    :address2
      t.string    :zip
      t.string    :city
      t.string    :phone1
      t.string    :phone2
      t.string    :cell
      t.string    :facsimile
      t.string    :email
      t.text      :comment
      t.integer   :group_id
      t.boolean   :disabled, :default => false
      
      # members only
      t.boolean   :in_training
      t.string    :fibunr #needed?
      t.string    :lvbnr
      #t.integer   :main_branch_id
      t.boolean   :primary_member,   :default => true
      t.text      :description
      t.date      :entry_date
      t.string    :ssv_member_state
      #- members only
      
      t.string    :type
      
      t.timestamps
    end
    add_index "people", ["id"], :name => "index_people_on_id", :unique => true
  end

  def self.down
    drop_table "people"
  end
end
