class WireLaunchCostItem < ActiveRecord::Base
  belongs_to :wire_launch_cost_rule
  belongs_to :financial_account

  def apply_to(wire_launch)
    CostItem.new(self, value || 0, financial_account)
  end
end
