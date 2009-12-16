ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  
  map.resources :person_cost_categories
  map.resources :plane_cost_categories
  map.resources :people
  map.resources :accounts
  map.resource :session
  map.resources :flights  
  map.resources :planes
  map.resources :airfields
  
  map.connect '/', :controller => 'flights', :action => 'index'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
