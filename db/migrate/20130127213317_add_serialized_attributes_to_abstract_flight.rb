class AddSerializedAttributesToAbstractFlight < ActiveRecord::Migration
  def change
    add_column :abstract_flights, :problems, :text
    add_column :abstract_flights, :cached_cost, :text
  end
end
