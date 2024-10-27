# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      include Pundit::Authorization
      before_action :check_json_request

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      private

      def check_json_request
        return if request.format.json? || 
                 request.headers['Accept']&.include?('application/json') ||
                 request.headers['Content-Type']&.include?('application/json')
                 
        redirect_to "#{Rails.configuration.frontend_url}/login", allow_other_host: true
      end

      def user_not_authorized
        render json: { error: 'Not authorized' }, status: :forbidden
      end

      def not_found
        render json: { error: 'Resource not found' }, status: :not_found
      end
    end
  end
end