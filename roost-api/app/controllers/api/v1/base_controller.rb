module Api
  module V1
    class BaseController < ApplicationController
      include Pundit::Authorization
      before_action :authenticate_user!
      
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      
      private
      
      def user_not_authorized
        render json: { error: 'Not authorized' }, status: :forbidden
      end
      
      def not_found
        render json: { error: 'Resource not found' }, status: :not_found
      end
    end
  end
end
