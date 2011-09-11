class AddProblemsExistToFlight < ActiveRecord::Migration
  def change
    add_column :abstract_flights, :problems_exist, :boolean
  end
end
