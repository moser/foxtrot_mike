class PlaneCostCategoryMembership < ActiveRecord::Base
  belongs_to :plane
  belongs_to :plane_cost_category
  include ValidityCheck
  #validates_presence_of :plane, :plane_cost_category
end
