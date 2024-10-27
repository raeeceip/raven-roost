Rails.application.routes.draw do
  # Remove path customizations for now to ensure default OAuth routes work
  devise_for :users, controllers: { 
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions'
  }

  # API Documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :auth do
        get '/validate_token', to: 'sessions#validate_token'
      end

      resources :users, only: [:index, :show, :create, :update, :destroy]
      resources :spaces, only: [:index, :show, :create, :update, :destroy] do
        member do
          post :update_occupancy
        end
      end
      resources :favorite_spaces, only: [:index, :create, :destroy]
      resources :search, only: [:index] do
        collection do
          get :suggest
        end
      end
    end
  end
end