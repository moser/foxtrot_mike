class AddSelfLaunchToPlane < ActiveRecord::Migration
  def change
    add_column :planes, :selflaunching, :boolean
  end
end
