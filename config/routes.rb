Server::Application.routes.draw do

  resources :financial_accounts do
    resource :overview, :controller => "financial_account_overviews"
  end

  match '/logout', :to => 'account_sessions#destroy'
  match '/login', :to => 'account_sessions#new'
  match 'dashboard', :to => 'dashboards#show'

  resources :groups do
    get :cost_overview, on: :member
    resources :people
  end
  resources :headers, :only => [:index]
  resources :people do
    collection do
      post 'import'
    end
    resources :person_cost_category_memberships
    resources :licenses
    resources :financial_account_ownerships
    resource :merge, only: [:create]
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
  end

  match ":filter_model/:filter_id/flights", to: "flights#index"
  match ":filter_model/:filter_id/flights/range/:range/search/:search", to: "flights#index"
  match ":filter_model/:filter_id/flights/range/:range", to: "flights#index"
  match ":filter_model/:filter_id/flights/search/:search", to: "flights#index"
  match "/flights/range/:range/search/:search", to: "flights#index"
  match "/flights/range/:range", to: "flights#index"
  match "/flights/search/:search", to: "flights#index"

  resources :accounting_entries do
    resource :destroy_confirmation
  end
  resources :accounting_sessions do
    resource :destroy_confirmation
    resources :manual_accounting_entries do
      post :import, on: :collection
    end
    resources :flights, :controller => 'accounting_session_flights'
  end
  resources :planes do
    collection do
      post 'import'
    end
    resources :plane_cost_category_memberships
    resources :financial_account_ownerships
  end
  resources :airfields do
    resource :main_log_book, :only => [:show], :controller => "pdfs"
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
  resources :licenses
  resources :legal_plane_classes
  resource :unknown_person
  resource :own_financial_account, :controller => "financial_account_overviews"

  resources :pdfs
  resources :csvs

  root :to => 'dashboards#show'

  match "/flights/day/:day_parse_date", :controller => "flights", :action => "index"
  match "/:controller(/:action(/:id))(.:format)"
end
