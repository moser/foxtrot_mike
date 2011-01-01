class PlaneCostCategory < ActiveRecord::Base
  include Membership
  has_many :plane_cost_category_memberships
  has_many :time_cost_rules
  has_many :tow_cost_rules
  membership :plane_cost_category_memberships
  
  validates_presence_of :name
  validates_inclusion_of :tow_cost_rule_type, :in => ["", "TowCostRule", "TimeCostRule"]
end
