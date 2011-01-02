class CreateCostHints < ActiveRecord::Migration
  def self.up
    create_table :cost_hints do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :cost_hints
  end
end
