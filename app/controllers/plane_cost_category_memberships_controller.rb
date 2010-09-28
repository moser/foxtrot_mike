class PlaneCostCategoryMembershipsController < ResourceController
  #before_filter :login_required
  nested :plane
end
