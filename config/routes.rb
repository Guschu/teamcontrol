Rails.application.routes.draw do
  resources :drivers

  resources :races do
    resources :teams
  end

  root to: 'races#index'
end
