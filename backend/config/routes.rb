Rails.application.routes.draw do
  # Authentication routes
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: 'sessions#failure'
  delete 'logout', to: 'sessions#destroy'
  
  # API routes - keep these before the catch-all
  namespace :api do
    namespace :v1 do
      resources :study_spaces, only: [:index, :show]
      resources :buildings, only: [:index, :show]
    end
  end
  
  # Main resource routes - keep these before the catch-all
  resources :study_spaces, only: [:index, :show] do
    collection do
      get 'search'
    end
    member do
      post 'toggle_favorite'
    end
  end
  
  get 'profile', to: 'profiles#show', as: :profile
  resources :favorites, only: [:index]

  # Static page routes
  get 'home', to: 'pages#home'
  get 'about', to: 'pages#about'
  get 'search', to: 'pages#search'
  get 'map', to: 'pages#map'
  
  # Root route
  root 'pages#home'

  # Astro view catch-all route - keep this last
  get '*path', to: 'pages#handle_astro_request', constraints: lambda { |req|
    !req.path.start_with?('/rails/') && 
    !req.path.start_with?('/cable') && 
    !req.path.start_with?('/api/') &&
    !req.path.start_with?('/assets/') &&
    req.headers['X-Requested-With'] == 'XMLHttpRequest'
  }
end