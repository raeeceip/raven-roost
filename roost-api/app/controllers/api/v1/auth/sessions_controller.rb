# app/controllers/api/v1/auth/sessions_controller.rb
module Api
    module V1
      module Auth
        class SessionsController < Api::V1::BaseController
          skip_before_action :authenticate_user!, only: [:validate_token]
          
          def validate_token
            begin
              header = request.headers['Authorization']
              token = header.split(' ').last if header
              decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
              
              user = User.find(decoded['user_id'])
              render json: { 
                valid: true, 
                user: {
                  id: user.id,
                  email: user.email,
                  name: user.name,
                  role: user.role,
                }
              }
            rescue JWT::DecodeError
              render json: { valid: false, error: 'Invalid token' }, status: :unauthorized
            rescue ActiveRecord::RecordNotFound
              render json: { valid: false, error: 'User not found' }, status: :unauthorized
            end
          end
        end
      end
    end
  end