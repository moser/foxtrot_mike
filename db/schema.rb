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

ActiveRecord::Schema.define(:version => 20091216153626) do

  create_table "accounts", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.integer  "person_id"
  end

  add_index "accounts", ["login"], :name => "index_accounts_on_login", :unique => true

  create_table "airfields", :force => true do |t|
    t.string   "name"
    t.string   "registration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cost_rules", :force => true do |t|
    t.string   "depends_on"
    t.integer  "rate"
    t.integer  "cost"
    t.string   "round"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crews", :force => true do |t|
    t.integer  "pic_id"
    t.integer  "co_id"
    t.integer  "trainee_id"
    t.integer  "instructor_id"
    t.integer  "passengers"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flights", :force => true do |t|
    t.integer  "duration"
    t.datetime "departure"
    t.integer  "from_id"
    t.integer  "to_id"
    t.integer  "plane_id"
    t.integer  "launch_id"
    t.integer  "crew_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "revisable_original_id"
    t.integer  "revisable_branched_from_id"
    t.integer  "revisable_number",           :default => 0
    t.string   "revisable_name"
    t.string   "revisable_type"
    t.datetime "revisable_current_at"
    t.datetime "revisable_revised_at"
    t.datetime "revisable_deleted_at"
    t.boolean  "revisable_is_current",       :default => true
  end

  create_table "launches", :force => true do |t|
    t.integer  "tow_flight_id"
    t.integer  "wire_launcher_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string   "lastname"
    t.string   "firstname"
    t.datetime "birthdate"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_cost_category_id"
    t.integer  "revisable_original_id"
    t.integer  "revisable_branched_from_id"
    t.integer  "revisable_number",           :default => 0
    t.string   "revisable_name"
    t.string   "revisable_type"
    t.datetime "revisable_current_at"
    t.datetime "revisable_revised_at"
    t.datetime "revisable_deleted_at"
    t.boolean  "revisable_is_current",       :default => true
  end

  create_table "person_cost_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plane_cost_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "planes", :force => true do |t|
    t.string   "registration"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "plane_cost_category_id"
    t.integer  "revisable_original_id"
    t.integer  "revisable_branched_from_id"
    t.integer  "revisable_number",           :default => 0
    t.string   "revisable_name"
    t.string   "revisable_type"
    t.datetime "revisable_current_at"
    t.datetime "revisable_revised_at"
    t.datetime "revisable_deleted_at"
    t.boolean  "revisable_is_current",       :default => true
    t.string   "make"
  end

end
