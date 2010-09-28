class PersonCostCategoryMembershipsController < ResourceController
  #before_filter :login_required  
  nested :person
end
