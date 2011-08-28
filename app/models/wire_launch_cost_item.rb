class WireLaunchCostItem < ActiveRecord::Base
  after_update :after_update_invalidate_accounting_entries
  
  belongs_to :wire_launch_cost_rule, :touch => true
  belongs_to :financial_account

  def apply_to(wire_launch)
    CostItem.new(self, value || 0, financial_account)
  end

private
  def after_update_invalidate_accounting_entries
    wire_launch_cost_rule.association_changed(nil)
  end
end
