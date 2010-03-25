class PlaneCostCategory < ActiveRecord::Base
  has_many :planes
  has_many :time_cost_rules
  has_many :tow_cost_rules
end
