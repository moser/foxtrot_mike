ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  
  map.resources :groups
  map.resources :people
  map.resources :accounts
  map.resource :session
  map.resources :flights
  map.resources :planes
  map.resources :airfields
  
  map.resources :person_cost_categories
  map.resources :plane_cost_categories
  map.resources :wire_launcher_cost_categories
  map.resources :person_cost_category_memberships
  map.resources :plane_cost_category_memberships
  map.resources :wire_launcher_cost_category_memberships
  map.resources :time_cost_rules
  map.resources :tow_cost_rules
  map.resources :wire_launch_cost_rules
  map.resources :plane_cost_rules
  
  map.connect '/', :controller => 'flights', :action => 'index'
  
  map.connect 'graveyard/:action.:format', :controller => 'graveyard'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
