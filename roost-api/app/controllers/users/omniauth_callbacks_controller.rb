# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Add CSRF protection skip for OAuth
  protect_from_forgery except: [:google_oauth2]
  
  def google_oauth2
    Rails.logger.info "Google OAuth2 callback hit" # Add logging
    
    @user = User.from_omniauth(request.env['omniauth.auth'])
    
    if @user.persisted?
      Rails.logger.info "User authenticated: #{@user.email}" # Add logging
      token = generate_jwt_token(@user)
      redirect_to "http://localhost:4321/auth/callback?token=#{token}"
    else
      Rails.logger.error "User authentication failed: #{@user.errors.full_messages}" # Add logging
      redirect_to "http://localhost:4321/auth/error", 
                  alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    Rails.logger.error "Authentication failed: #{failure_message}" # Add logging
    redirect_to "http://localhost:4321/auth/error", 
                alert: failure_message
  end

  private

  def generate_jwt_token(user)
    JWT.encode(
      {
        user_id: user.id,
        email: user.email,
        exp: 24.hours.from_now.to_i
      },
      Rails.application.credentials.secret_key_base
    )
  end
end