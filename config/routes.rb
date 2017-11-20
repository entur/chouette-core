require 'sidekiq/web'

ChouetteIhm::Application.routes.draw do
  resource :dashboard

  resources :workbenches, only: [:show, :index] do
    delete :referentials, on: :member, action: :delete_referentials

    get :output, to: 'referential_suites#index' 
    resources :imports do
      get :download, on: :member
      resources :import_resources, only: [:index] do
        resources :import_messages, only: [:index]
      end
    end
    resources :compliance_check_sets, only: [:index, :show] do
      get :executed, on: :member
      resources :compliance_checks, only: [:show]
    end
  end

  devise_for :users, :controllers => {
    :registrations => 'users/registrations', :invitations => 'users/invitations'
  }

  devise_scope :user do
    authenticated :user do
      root :to => 'workbenches#index', as: :authenticated_root
    end

    unauthenticated :user do
      target = 'devise/sessions#new'

      if Rails.application.config.chouette_authentication_settings[:type] == "cas"
        target = 'devise/cas_sessions#new'
      end

      root :to => target, as: :unauthenticated_root
    end
  end

  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      resources :workbenches, only: [:index, :show] do
        resources :imports, only: [:index, :show, :create]
      end
      resources :access_links, only: [:index, :show]
      resources :access_points, only: [:index, :show]
      resources :connection_links, only: [:index, :show]
      resources :companies, only: [:index, :show]
      resources :group_of_lines, only: [:index, :show]
      resources :netex_imports, only: :create
      resources :journey_patterns, only: :show
      resources :lines, only: [:index, :show] do
        resources :journey_patterns, only: [:index, :show]
        resources :routes, only: [:index, :show] do
          resources :vehicle_journeys, only: [:index, :show]
          resources :journey_patterns, only: [:index, :show]
          resources :stop_areas, only: [:index, :show]
        end
      end
      resources :networks, only: [:index, :show]
      resources :routes, only: :show
      resources :stop_areas, only: [:index, :show]
      resources :time_tables, only: [:index, :show]
      resources :vehicle_journeys, only: :show
      patch 'compliance_check_sets/:id',
        to: 'compliance_check_sets#validated',
        as: 'compliance_check_set'
    end
  end

  resource :organisation, :only => [:show, :edit, :update] do
    resources :users
  end

  resources :api_keys, :only => [:edit, :update, :new, :create, :destroy]

  resources :compliance_control_sets do
    get :simple, on: :member
    get :clone, on: :member
    resources :compliance_controls, except: :index do
      get :select_type, on: :collection
    end
    resources :compliance_control_blocks, :except => [:show, :index]
  end

  resources :stop_area_referentials, :only => [:show] do
    post :sync, on: :member
    resources :stop_areas
  end

  resources :line_referentials, :only => [:show, :edit, :update] do
    post :sync, on: :member
    resources :lines
    resources :group_of_lines
    resources :companies
    resources :networks
  end

  resources :calendars do
    get :autocomplete, on: :collection, controller: 'autocomplete_calendars'
  end

  resources :referentials, except: :index do
    resources :autocomplete_stop_areas, only: [:show, :index] do
      get 'around', on: :member
    end
    get :select_compliance_control_set
    post :validate, on: :member
    resources :autocomplete_time_tables, only: [:index]
    resources :autocomplete_timebands
    resources :group_of_lines, controller: "referential_group_of_lines" do
      collection do
        get 'name_filter'
      end
    end

    # Archive/unarchive
    member do
      put :archive
      put :unarchive
    end

    resources :networks, controller: "referential_networks"

    match 'lines' => 'lines#destroy_all', :via => :delete
    resources :lines, controller: "referential_lines", except: :index do
      resource :footnotes, controller: "line_footnotes"
      delete :index, on: :collection, action: :delete_all
      collection do
        get 'name_filter'
      end
      resources :routes do
        member do
          get 'edit_boarding_alighting'
          put 'save_boarding_alighting'
          post 'duplicate', to: 'routes#duplicate'
        end
        resource :journey_patterns_collection, :only => [:show, :update]
        resources :journey_patterns do
          get 'new_vehicle_journey', on: :member
        end
        resource :vehicle_journeys_collection, :only => [:show, :update]
        resources :vehicle_journeys, :vehicle_journey_frequencies do
          get 'select_journey_pattern', :on => :member
          get 'select_vehicle_journey', :on => :member
          resources :vehicle_translations
          resources :time_tables
        end
        resources :vehicle_journey_imports
        resources :vehicle_journey_exports
        resources :stop_points, only: :index, controller: 'route_stop_points'
      end
      resources :routing_constraint_zones
    end

    resources :import_tasks, :only => [:new, :create]
    resources :export_tasks, :only => [:new, :create] do
      collection do
        get 'references'
      end
    end

    resources :exports, :only => [:index, :show, :destroy]  do
      member do
        get "exported_file"
      end
    end

    resources :companies, controller: "referential_companies"

    resources :time_tables do
      collection do
        get :tags
      end
      member do
        post 'actualize'
        get 'duplicate'
        get 'month', defaults: { format: :json }
      end
      resources :time_table_dates
      resources :time_table_periods
      resources :time_table_combinations
    end

    resources :timebands

    resources :access_points do
      resources :access_links
    end

    resources :stop_areas, controller: "referential_stop_areas" do
      resources :access_points
      resources :stop_area_copies
      resources :stop_area_routing_lines
      member do
        get 'add_children'
        get 'select_parent'
        get 'add_routing_lines'
        get 'add_routing_stops'
        get 'access_links'
      end
      collection do
        put 'default_geometry'
      end
    end

    resources :connection_links do
      resources :stop_areas
      member do
        get 'select_areas'
      end
    end
    resources :clean_ups
  end

  root :to => "dashboards#show"

  get '/help/(*slug)' => 'help#show'

  match '/404', to: 'errors#not_found', via: :all, as: 'not_found'
  match '/403', to: 'errors#forbidden', via: :all, as: 'forbidden'
  match '/422', to: 'errors#server_error', via: :all, as: 'unprocessable_entity'
  match '/500', to: 'errors#server_error', via: :all, as: 'server_error'

end
