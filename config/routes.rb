Server::Application.routes.draw do  

  resources :financial_accounts

  match '/logout', :to => 'account_sessions#destroy'
  match '/login', :to => 'account_sessions#new'
  match 'dashboard', :to => 'dashboards#show'
  
  resources :groups do
    resources :flights
  end
  resources :headers, :only => [:index]
  resources :people do
    resources :person_cost_category_memberships
    resources :licenses
  end
  resources :accounts
  resources :account_sessions
  resources :flights
  resources :tow_flights, :controller => 'flights'
  resources :planes do
    resources :flights, :only => [:index]
    resource :timeline, :only => [:show]
    resources :plane_cost_category_memberships
  end
  resources :airfields do
    resources :flights, :only => [:index]
  end
  resources :wire_launchers do
    resources :wire_launcher_cost_category_memberships
  end
  
  resources :person_cost_categories
  resources :plane_cost_categories
  resources :wire_launcher_cost_categories
  resources :person_cost_category_memberships
  resources :plane_cost_category_memberships
  resources :wire_launcher_cost_category_memberships
  resources :time_cost_rules
  resources :tow_cost_rules
  resources :wire_launch_cost_rules
  resources :plane_cost_rules
  resources :wire_launcher_cost_rules
  resources :licenses do
    resources :flights, :only => [:index]
    resource :timeline, :only => [:show]
  end
  resources :legal_plane_classes  
  
  root :to => 'dashboards#show'
  
  match "/:controller(/:action(/:id))(.:format)"
end
