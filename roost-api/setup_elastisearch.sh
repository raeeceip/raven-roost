#!/bin/bash

# Exit on error
set -e

echo "🚀 Setting up OAuth and Elasticsearch for Roost API..."

# Add necessary gems to Gemfile
cat << 'EOF' >> Gemfile

# OAuth
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-microsoft-office365'
gem 'omniauth-rails_csrf_protection'

# Elasticsearch
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'searchkick'

# Background jobs for indexing
gem 'sidekiq'
EOF

# Install new gems
bundle install

# Generate OAuth configuration
rails generate migration add_oauth_to_users provider:string uid:string access_token:string refresh_token:string

# Create OAuth initializer
cat << 'EOF' > config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV['GOOGLE_CLIENT_ID'],
           ENV['GOOGLE_CLIENT_SECRET'],
           {
             scope: 'email,profile',
             prompt: 'select_account'
           }

  provider :microsoft_office365,
           ENV['MICROSOFT_CLIENT_ID'],
           ENV['MICROSOFT_CLIENT_SECRET'],
           {
             scope: 'openid email profile'
           }
end

OmniAuth.config.allowed_request_methods = [:post, :get]
EOF

# Create OAuth controller
mkdir -p app/controllers/users
cat << 'EOF' > app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_auth("Google")
  end

  def microsoft_office365
    handle_auth("Microsoft")
  end

  private

  def handle_auth(kind)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
    else
      session["devise.auth_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end
EOF

# Update User model with OAuth support
cat << 'EOF' > app/models/concerns/omniauthable.rb
module Omniauthable
  extend ActiveSupport::Concern

  class_methods do
    def from_omniauth(auth)
      user = User.where(email: auth.info.email).first

      if user
        user.update(
          provider: auth.provider,
          uid: auth.uid,
          access_token: auth.credentials.token,
          refresh_token: auth.credentials.refresh_token
        )
      else
        user = User.create(
          email: auth.info.email,
          name: auth.info.name,
          password: Devise.friendly_token[0, 20],
          provider: auth.provider,
          uid: auth.uid,
          access_token: auth.credentials.token,
          refresh_token: auth.credentials.refresh_token
        )
      end

      user
    end
  end
end
EOF

# Update User model
cat << 'EOF' > app/models/user.rb
class User < ApplicationRecord
  include Omniauthable
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :microsoft_office365]

  # ... rest of the model
end
EOF

# Setup Elasticsearch
cat << 'EOF' > config/initializers/elasticsearch.rb
ENV['ELASTICSEARCH_URL'] = ENV.fetch('ELASTICSEARCH_URL', 'http://localhost:9200')

if Rails.env.development?
  logger = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = proc { |severity, datetime, progname, msg| "\n#{msg}\n" }
  Searchkick.client.transport.logger = logger
end
EOF

# Add Elasticsearch to Space model
cat << 'EOF' > app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern

  included do
    searchkick word_start: [:name, :building],
              suggest: [:name],
              searchable: [:name, :building, :status, :amenities],
              callbacks: :async

    def search_data
      {
        name: name,
        building: building,
        status: status,
        amenities: amenities,
        current_occupancy: current_occupancy,
        capacity: capacity,
        occupancy_rate: (current_occupancy.to_f / capacity * 100).round(2),
        created_at: created_at
      }
    end
  end
end
EOF

# Update Space model
cat << 'EOF' > app/models/space.rb
class Space < ApplicationRecord
  include Searchable
  
  # ... rest of the model

  # Search method
  def self.search_spaces(query, filters = {})
    search_options = {
      fields: ["name^3", "building^2", "amenities"],
      where: {},
      aggs: {
        building: {},
        status: {},
        amenities: {}
      },
      smart_aggs: true,
      order: { _score: :desc },
      page: filters[:page],
      per_page: 20
    }

    # Add filters
    search_options[:where][:building] = filters[:building] if filters[:building].present?
    search_options[:where][:status] = filters[:status] if filters[:status].present?
    
    if filters[:min_capacity].present?
      search_options[:where][:capacity] = { gte: filters[:min_capacity] }
    end

    if filters[:available_now].present? && filters[:available_now]
      search_options[:where][:status] = 'available'
    end

    search(query, search_options)
  end
end
EOF

# Create search controller
cat << 'EOF' > app/controllers/api/v1/search_controller.rb
module Api
  module V1
    class SearchController < BaseController
      skip_before_action :authenticate_user!, only: [:index]

      def index
        @spaces = Space.search_spaces(
          params[:query],
          {
            building: params[:building],
            status: params[:status],
            min_capacity: params[:min_capacity],
            available_now: params[:available_now],
            page: params[:page]
          }
        )

        render json: {
          spaces: SpaceSerializer.new(@spaces).serializable_hash,
          meta: {
            total_count: @spaces.total_count,
            total_pages: @spaces.total_pages,
            current_page: @spaces.current_page,
            aggregations: @spaces.aggs
          }
        }
      end

      def suggest
        suggestions = Space.search(
          params[:term],
          fields: [{name: :word_start}],
          limit: 5,
          suggest: true
        ).suggestions

        render json: suggestions
      end
    end
  end
end
EOF

# Create Sidekiq configuration
cat << 'EOF' > config/sidekiq.yml
:concurrency: 5
:queues:
  - default
  - searchkick
EOF

# Add environment variables template
cat << 'EOF' > .env.example
# OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
MICROSOFT_CLIENT_ID=your_microsoft_client_id
MICROSOFT_CLIENT_SECRET=your_microsoft_client_secret

# Elasticsearch
ELASTICSEARCH_URL=http://localhost:9200

# Redis for Sidekiq
REDIS_URL=redis://localhost:6379/1
EOF

# Update routes
cat << 'EOF' >> config/routes.rb
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  
  namespace :api do
    namespace :v1 do
      resources :search, only: [:index] do
        collection do
          get :suggest
        end
      end
    end
  end
EOF

# Add Elasticsearch service to docker-compose
cat << 'EOF' > docker-compose.yml
version: '3'

services:
  elasticsearch:
    image: elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data

  redis:
    image: redis:7.2
    ports:
      - "6379:6379"

volumes:
  elasticsearch-data:
EOF

echo "✅ OAuth and Elasticsearch setup complete!"
echo ""
echo "Next steps:"
echo "1. Create OAuth applications in Google and Microsoft Developer Consoles"
echo "2. Copy .env.example to .env and add your OAuth credentials"
echo "3. Start services: docker-compose up -d"
echo "4. Run migrations: rails db:migrate"
echo "5. Reindex Elasticsearch: rails c"
echo "   > Space.reindex"
echo ""
echo "To test search:"
echo "curl http://localhost:3000/api/v1/search?query=library&building=MacOdrum"
E