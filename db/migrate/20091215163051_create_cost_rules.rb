class CreateCostRules < ActiveRecord::Migration
  def self.up
    create_table :cost_rules do |t|
      t.string :depends_on
      t.integer :rate
      t.integer :cost
      t.string :round

      t.timestamps
    end
  end

  def self.down
    drop_table :cost_rules
  end
end
