Rails.application.routes.draw do
  mount SwaggerUI, at: 'docs/api'
  mount API => 'api'

  resources :drivers

  resources :races do
    resources :teams
  end

  root to: 'races#index'
end
