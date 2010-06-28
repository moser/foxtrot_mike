# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100623141040) do

  create_table "abstract_flights", :id => false, :force => true do |t|
    t.string   "id",              :limit => 36
    t.string   "plane_id",        :limit => 36
    t.string   "from_id",         :limit => 36
    t.string   "to_id",           :limit => 36
    t.string   "controller_id",   :limit => 36
    t.datetime "departure"
    t.integer  "duration"
    t.integer  "engine_duration"
    t.string   "purpose"
    t.text     "comment"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "abstract_flights", ["id"], :name => "index_abstract_flights_on_id", :unique => true

  create_table "accounts", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "person_id",                 :limit => 36
  end

  add_index "accounts", ["login"], :name => "index_accounts_on_login", :unique => true

  create_table "airfields", :id => false, :force => true do |t|
    t.string   "id",           :limit => 36
    t.string   "name"
    t.string   "registration"
    t.boolean  "disabled",                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "airfields", ["id"], :name => "index_airfields_on_id", :unique => true

  create_table "crew_members", :id => false, :force => true do |t|
    t.string   "id",                 :limit => 36
    t.string   "abstract_flight_id"
    t.string   "person_id"
    t.integer  "n"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "crew_members", ["id"], :name => "index_crew_members_on_id", :unique => true

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "launches", :id => false, :force => true do |t|
    t.string   "id",                 :limit => 36
    t.string   "abstract_flight_id", :limit => 36
    t.string   "tow_flight_id",      :limit => 36
    t.string   "wire_launcher_id",   :limit => 36
    t.integer  "tow_level_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "launches", ["id"], :name => "index_launches_on_id", :unique => true

  create_table "liabilities", :id => false, :force => true do |t|
    t.string   "id"
    t.string   "flight_id"
    t.string   "person_id"
    t.datetime "booked_at"
    t.integer  "proportion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manual_costs", :force => true do |t|
    t.string   "flight_id",  :limit => 36
    t.string   "launch_id",  :limit => 36
    t.integer  "value"
    t.text     "comment"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :id => false, :force => true do |t|
    t.string   "id",               :limit => 36
    t.string   "lastname"
    t.string   "firstname"
    t.date     "birthdate"
    t.string   "title"
    t.string   "sex"
    t.string   "address1"
    t.string   "address2"
    t.string   "zip"
    t.string   "city"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "cell"
    t.string   "facsimile"
    t.string   "email"
    t.text     "comment"
    t.integer  "group_id"
    t.boolean  "disabled",                       :default => false
    t.boolean  "in_training"
    t.string   "fibunr"
    t.string   "lvbnr"
    t.boolean  "primary_member",                 :default => true
    t.text     "description"
    t.date     "entry_date"
    t.string   "ssv_member_state"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["id"], :name => "index_people_on_id", :unique => true

  create_table "person_cost_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "person_cost_category_memberships", :force => true do |t|
    t.string   "person_id",               :limit => 36
    t.integer  "person_cost_category_id"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plane_cost_categories", :force => true do |t|
    t.string   "name"
    t.string   "tow_cost_rule_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plane_cost_category_memberships", :force => true do |t|
    t.string   "plane_id",               :limit => 36
    t.integer  "plane_cost_category_id"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "planes", :id => false, :force => true do |t|
    t.string   "id",                     :limit => 36
    t.string   "registration"
    t.string   "make"
    t.string   "competition_sign"
    t.string   "editor_id",              :limit => 36
    t.integer  "group_id"
    t.string   "default_launch_method"
    t.boolean  "has_engine"
    t.boolean  "can_fly_without_engine"
    t.boolean  "can_tow"
    t.boolean  "can_be_towed"
    t.boolean  "can_be_wire_launched"
    t.boolean  "disabled",                             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "planes", ["id"], :name => "index_planes_on_id", :unique => true

  create_table "time_cost_rules", :force => true do |t|
    t.integer  "person_cost_category_id"
    t.integer  "plane_cost_category_id"
    t.integer  "cost"
    t.string   "name"
    t.string   "flight_type"
    t.string   "depends_on"
    t.string   "condition_field"
    t.string   "condition_operator"
    t.string   "comment"
    t.integer  "condition_value",         :default => 0
    t.integer  "additive_cost",           :default => 0
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tow_cost_rules", :force => true do |t|
    t.integer  "person_cost_category_id"
    t.integer  "plane_cost_category_id"
    t.string   "name"
    t.string   "comment"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tow_levels", :force => true do |t|
    t.string   "name"
    t.integer  "tow_cost_rule_id"
    t.integer  "cost"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",          :null => false
    t.string   "item_id",            :null => false
    t.string   "event",              :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.string   "abstract_flight_id"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "wire_launch_cost_rules", :force => true do |t|
    t.integer  "person_cost_category_id"
    t.integer  "wire_launcher_cost_category_id"
    t.integer  "cost"
    t.string   "name"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wire_launcher_cost_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wire_launcher_cost_category_memberships", :force => true do |t|
    t.string   "wire_launcher_id",               :limit => 36
    t.integer  "wire_launcher_cost_category_id"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wire_launchers", :id => false, :force => true do |t|
    t.string   "id",           :limit => 36
    t.string   "registration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wire_launchers", ["id"], :name => "index_wire_launchers_on_id", :unique => true

end
