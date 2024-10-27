Rails.application.routes.draw do
  devise_for :users
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Authentication routes
      post '/auth/login', to: 'auth#login'
      post '/auth/register', to: 'auth#register'

      # User routes
      resources :users, only: [:index, :show, :create, :update, :destroy]

      # Space routes
      resources :spaces, only: [:index, :show, :create, :update, :destroy] do
        member do
          post :update_occupancy
        end
      end

      # FavoriteSpace routes
      resources :favorite_spaces, only: [:index, :create, :destroy]
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end