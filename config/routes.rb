Rails.application.routes.draw do
  devise_for :users
  mount SwaggerUI, at: 'docs/api'
  mount API => 'api'

  namespace :admin do
    resources :stations
    resources :users
  end

  resources :drivers
  resources :races do
    resources :teams do
      collection do
        post 'handle_team_login'
        post 'import'
      end

      member do
        post 'move_up'
        post 'move_down'
        post 'set_registrating'
      end
    end
    resources :events, only: [:index, :create, :destroy] do
      member do
        get 'details'
        post 'adjust'
      end
    end
    resources :penalties, only: [:index]

    member do
      get 'public_overview'
      get 'overview'
      get 'settings'

      # AASM events
      post 'start'
      post 'finish'
      post 'stop_registrating'
    end
  end

  root to: 'races#current'
end
