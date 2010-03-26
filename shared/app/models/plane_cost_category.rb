class PlaneCostCategory < ActiveRecord::Base
  has_many :plane_cost_category_memberships
  has_many :time_cost_rules
  has_many :tow_cost_rules
  
  validates_inclusion_of :tow_cost_rule_type, :in => ["", "TowCostRule", "TimeCostRule"]
end
