class AddWarnWhenNoCostRulesToPlane < ActiveRecord::Migration
  def change
    add_column :planes, :warn_when_no_cost_rules, :boolean, :default => false
  end
end
