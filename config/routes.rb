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
        post 'import'
      end
    end
    resources :events, only: [:index, :create]

    member do
      get 'overview'
      get 'settings'

      # AASM events
      post 'start'
      post 'finish'
    end
  end

  root to: 'races#current'
end
