# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120106124854) do

  create_table "abstract_flights", :id => false, :force => true do |t|
    t.string   "id",                       :limit => 36
    t.string   "plane_id",                 :limit => 36
    t.string   "from_id",                  :limit => 36
    t.string   "to_id",                    :limit => 36
    t.string   "controller_id",            :limit => 36
    t.string   "launch_id",                :limit => 36
    t.string   "launch_type"
    t.date     "departure_date"
    t.integer  "departure_i",                            :default => -1
    t.integer  "arrival_i",                              :default => -1
    t.integer  "engine_duration",                        :default => -1
    t.text     "comment"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost_hint_id"
    t.integer  "accounting_session_id"
    t.boolean  "accounting_entries_valid",               :default => false
    t.boolean  "problems_exist"
  end

  add_index "abstract_flights", ["id"], :name => "index_abstract_flights_on_id", :unique => true

  create_table "accounting_entries", :force => true do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.integer  "value"
    t.integer  "accounting_session_id"
    t.string   "item_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_sessions", :force => true do |t|
    t.string   "name"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "end_date"
    t.date     "start_date"
  end

  create_table "accounts", :force => true do |t|
    t.string   "person_id",           :limit => 36
    t.string   "login",                                                :null => false
    t.string   "crypted_password",                                     :null => false
    t.string   "password_salt",                                        :null => false
    t.string   "persistence_token",                                    :null => false
    t.string   "single_access_token",                                  :null => false
    t.string   "perishable_token",                                     :null => false
    t.integer  "login_count",                       :default => 0,     :null => false
    t.integer  "failed_login_count",                :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                             :default => false
    t.boolean  "license_official",                  :default => false
    t.boolean  "treasurer",                         :default => false
    t.boolean  "controller",                        :default => false
    t.boolean  "reader",                            :default => false
  end

  add_index "accounts", ["login"], :name => "index_accounts_on_login", :unique => true

  create_table "airfields", :id => false, :force => true do |t|
    t.string   "id",           :limit => 36
    t.string   "name"
    t.string   "registration"
    t.boolean  "disabled",                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "lat",                        :default => 0.0
    t.float    "long",                       :default => 0.0
    t.boolean  "home",                       :default => false
  end

  add_index "airfields", ["id"], :name => "index_airfields_on_id", :unique => true

  create_table "cost_hints", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cost_rule_conditions", :force => true do |t|
    t.integer  "cost_rule_id"
    t.integer  "cost_hint_id"
    t.integer  "condition_value_i"
    t.string   "condition_field"
    t.string   "condition_operator"
    t.string   "condition_value_s"
    t.string   "cost_rule_type"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "financial_account_ownerships", :force => true do |t|
    t.string   "owner_id"
    t.string   "owner_type"
    t.integer  "financial_account_id"
    t.date     "valid_from"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "financial_accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "number",     :default => ""
  end

  create_table "flight_cost_items", :force => true do |t|
    t.integer  "value"
    t.integer  "additive_value"
    t.integer  "financial_account_id"
    t.string   "depends_on"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flight_cost_rule_id"
  end

  create_table "flight_cost_rules", :force => true do |t|
    t.string   "name"
    t.string   "flight_type"
    t.integer  "plane_cost_category_id"
    t.integer  "person_cost_category_id"
    t.date     "valid_from"
    t.date     "valid_to"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "legal_plane_classes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "legal_plane_classes_licenses", :id => false, :force => true do |t|
    t.integer "legal_plane_class_id"
    t.integer "license_id"
  end

  create_table "liabilities", :id => false, :force => true do |t|
    t.string   "id"
    t.string   "flight_id"
    t.string   "person_id"
    t.integer  "proportion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "licenses", :force => true do |t|
    t.string   "name"
    t.string   "level",                    :default => "normal", :null => false
    t.date     "valid_from"
    t.date     "valid_to"
    t.string   "person_id",  :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manual_costs", :id => false, :force => true do |t|
    t.string   "id",         :limit => 36, :null => false
    t.string   "item_id",    :limit => 36
    t.string   "item_type"
    t.integer  "value"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "manual_costs", ["id"], :name => "index_manual_costs_on_id", :unique => true

  create_table "people", :id => false, :force => true do |t|
    t.string   "id",             :limit => 36
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
    t.boolean  "disabled",                     :default => false
    t.boolean  "in_training"
    t.string   "lvbnr"
    t.boolean  "primary_member",               :default => true
    t.date     "entry_date"
    t.string   "member_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "member"
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
    t.date     "valid_from"
    t.date     "valid_to"
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
    t.date     "valid_from"
    t.date     "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "planes", :id => false, :force => true do |t|
    t.string   "id",                                  :limit => 36
    t.string   "registration"
    t.string   "make"
    t.string   "competition_sign"
    t.string   "editor_id",                           :limit => 36
    t.integer  "group_id"
    t.integer  "legal_plane_class_id"
    t.string   "default_launch_method"
    t.boolean  "has_engine"
    t.boolean  "can_fly_without_engine"
    t.boolean  "can_tow"
    t.boolean  "can_be_towed"
    t.boolean  "can_be_wire_launched"
    t.boolean  "disabled",                                          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "selflaunching"
    t.integer  "seat_count"
    t.boolean  "default_engine_duration_to_duration"
    t.boolean  "warn_when_no_cost_rules",                           :default => false
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
    t.date     "valid_from"
    t.date     "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tow_cost_rules", :force => true do |t|
    t.integer  "person_cost_category_id"
    t.integer  "plane_cost_category_id"
    t.string   "name"
    t.string   "comment"
    t.date     "valid_from"
    t.date     "valid_to"
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
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "wire_launch_cost_items", :force => true do |t|
    t.string   "name"
    t.integer  "value"
    t.integer  "financial_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "wire_launch_cost_rule_id"
  end

  create_table "wire_launch_cost_rules", :force => true do |t|
    t.integer  "person_cost_category_id"
    t.integer  "wire_launcher_cost_category_id"
    t.string   "name"
    t.date     "valid_from"
    t.date     "valid_to"
    t.text     "comment"
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
    t.date     "valid_from"
    t.date     "valid_to"
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

  create_table "wire_launches", :id => false, :force => true do |t|
    t.string   "id",                       :limit => 36
    t.string   "wire_launcher_id",         :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accounting_entries_valid",               :default => false
    t.string   "operator_id"
  end

  add_index "wire_launches", ["id"], :name => "index_wire_launches_on_id", :unique => true

end
