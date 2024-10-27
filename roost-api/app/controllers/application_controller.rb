# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  respond_to :json

  def authenticate_user!
    if user_signed_in?
      super
    else
      if api_request?
        render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
      else
        redirect_to "#{Rails.configuration.frontend_url}/login", allow_other_host: true
      end
    end
  end

  private

  def api_request?
    request.format.json? || 
    request.headers['Accept']&.include?('application/json') ||
    request.headers['Content-Type']&.include?('application/json')
  end
end