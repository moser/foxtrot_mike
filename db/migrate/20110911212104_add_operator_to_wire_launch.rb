class AddOperatorToWireLaunch < ActiveRecord::Migration
  def change
    add_column :wire_launches, :operator_id, :string
  end
end
