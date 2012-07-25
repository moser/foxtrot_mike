class WireLauncherCostCategoryMembershipsController < ResourceController
  #before_filter :login_required  
  nested :wire_launcher
end
