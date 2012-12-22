class FlightIdToInt < ActiveRecord::Migration
  def up
    AccountingSession.delete_all
    AccountingEntry.delete_all
    AbstractFlight.destroy_all
    WireLaunch.destroy_all

    drop_table :abstract_flights
    create_table "abstract_flights" do |t|
      t.string   "plane_id",                 :limit => 36
      t.string   "from_id",                  :limit => 36
      t.string   "to_id",                    :limit => 36
      t.string   "controller_id",            :limit => 36
      t.integer  "launch_id"    
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
      t.string   "seat1_person_id"
      t.string   "seat2_person_id"
      t.integer  "seat2_n",                                :default => 0
    end

    drop_table :wire_launches
    create_table "wire_launches" do |t|
      t.string   "wire_launcher_id",         :limit => 36
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "accounting_entries_valid",               :default => false
      t.string   "operator_id"
    end

    remove_column :accounting_entries, :item_id
    add_column :accounting_entries, :item_id, :integer

    remove_column :liabilities, :flight_id
    add_column :liabilities, :flight_id, :integer

    remove_column :versions, :abstract_flight_id
    add_column :versions, :abstract_flight_id, :integer

  end

  def down
    raise "This was irreversible"
  end
end
