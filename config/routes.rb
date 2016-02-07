Rails.application.routes.draw do
  resources :races

  root to: 'races#index'
end
