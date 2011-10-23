class AddDefaultEngineDurationToDurationToPlane < ActiveRecord::Migration
  def change
    add_column :planes, :default_engine_duration_to_duration, :boolean
  end
end
