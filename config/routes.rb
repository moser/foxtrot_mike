Server::Application.routes.draw do

  resources :financial_accounts do
    resources :advance_payments, :only => [ :show, :new, :create ]
  end

  match '/logout', :to => 'account_sessions#destroy'
  match '/login', :to => 'account_sessions#new'
  match 'dashboard', :to => 'dashboards#show'

  resources :filtered_flights, :only => [:index]
  resources :groups do
    resources :flights, :controller => 'filtered_flights', :only => [:index]
  end
  resources :headers, :only => [:index]
  resources :people do
    resources :person_cost_category_memberships
    resources :licenses
    resources :flights, :controller => 'filtered_flights', :only => [:index]
    resources :financial_account_ownerships
  end
  resources :accounts do
    resource :password, :only => [ :new, :create ]
  end
  resource :password, :only => [ :new, :create ]
  resources :account_sessions
  resources :flights do
    resource :launch
    resources :liabilities
    resources :accounting_entries
    resource :destroy_confirmation
  end
  resources :accounting_sessions do
    resources :flights, :controller => 'accounting_session_flights'
  end
  resources :tow_flights, :controller => 'flights'
  resources :planes do
    resources :flights, :controller => 'filtered_flights', :only => [:index]
    resources :plane_cost_category_memberships
    resources :financial_account_ownerships
  end
  resources :airfields do
    resource :main_log_book, :only => [:show]
  end
  resources :wire_launchers do
    resources :wire_launcher_cost_category_memberships
    resources :financial_account_ownerships
  end

  resources :person_cost_categories
  resources :plane_cost_categories
  resources :wire_launcher_cost_categories
  resources :person_cost_category_memberships
  resources :plane_cost_category_memberships
  resources :liabilities
  resources :wire_launcher_cost_category_memberships
  resources :flight_cost_rules do
    resources :cost_rule_conditions
    resources :flight_cost_items
  end
  resources :flight_cost_items
  resources :cost_rule_conditions
  resources :cost_hint_conditions, :controller => "cost_rule_conditions"
  resources :number_cost_rule_conditions, :controller => "cost_rule_conditions"
  resources :wire_launch_cost_rules do
    resources :cost_rule_conditions
    resources :wire_launch_cost_items
  end
  resources :wire_launch_cost_items
  resources :financial_account_ownerships

  resources :cost_rules
  resources :cost_hints
  resources :licenses do
    resources :flights, :controller => 'filtered_flights', :only => [:index]
  end
  resources :legal_plane_classes
  resource :unknown_person
  resource :own_financial_account

  root :to => 'dashboards#show'

  match "/flights/day/:day_parse_date", :controller => "flights", :action => "index"
  match "/:controller(/:action(/:id))(.:format)"
end
