Rails.application.routes.draw do
  mount SwaggerUI, at: 'docs/api'
  mount API => 'api'

  namespace :admin do
    resources :stations
  end

  resources :drivers
  resources :races do
    resources :teams
  end

  root to: 'races#index'
end
