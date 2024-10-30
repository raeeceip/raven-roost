# config/routes.rb
Rails.application.routes.draw do
  # Root route
  root 'pages#home'
  
  # Authentication routes
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: 'sessions#failure'
  delete 'logout', to: 'sessions#destroy'
  
  # Main routes
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
  
  # API routes
  namespace :api do
    namespace :v1 do
      resources :study_spaces, only: [:index, :show]
      resources :buildings, only: [:index, :show]
    end
  end
end