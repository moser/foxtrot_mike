class AddHomeToAirfield < ActiveRecord::Migration
  def change
    add_column :airfields, :home, :boolean, :default => false
  end
end
