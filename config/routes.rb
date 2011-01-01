Server::Application.routes.draw do  

  resources :financial_accounts

  match '/logout', :to => 'account_sessions#destroy'
  match '/login', :to => 'account_sessions#new'
  match 'dashboard', :to => 'dashboards#show'

  resources :pdfs, :only => [:show, :create]
  resources :filtered_flights, :only => [:index]
  resources :groups do
    resources :flights, :controller => 'filtered_flights', :only => [:index]
  end
  resources :headers, :only => [:index]
  resources :people do
    resources :person_cost_category_memberships
    resources :licenses
    resources :flights, :controller => 'filtered_flights', :only => [:index]
  end
  resources :accounts
  resources :account_sessions
  resources :flights do 
    resource :launch
    resources :liabilities
    resources :accounting_entries
  end
  resources :tow_flights, :controller => 'flights'
  resources :planes do
    resources :flights, :controller => 'filtered_flights', :only => [:index]
    resource :timeline, :only => [:show]
    resources :plane_cost_category_memberships
  end
  resources :airfields do
    resource :main_log_book, :only => [:show]
  end
  resources :wire_launchers do
    resources :wire_launcher_cost_category_memberships
  end
  
  resources :person_cost_categories
  resources :plane_cost_categories
  resources :wire_launcher_cost_categories
  resources :person_cost_category_memberships
  resources :plane_cost_category_memberships
  resources :liabilities
  resources :wire_launcher_cost_category_memberships
  resources :time_cost_rules
  resources :tow_cost_rules
  resources :wire_launch_cost_rules
  resources :cost_rules
  resources :wire_launcher_cost_rules
  resources :licenses do
    resources :flights, :controller => 'filtered_flights', :only => [:index]
    resource :timeline, :only => [:show]
  end
  resources :legal_plane_classes  
  
  root :to => 'dashboards#show'
  
  match "/:controller(/:action(/:id))(.:format)"
end
