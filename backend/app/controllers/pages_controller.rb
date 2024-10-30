# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  def home
    @featured_spaces = StudySpace.where(status: 'available').limit(3)
    @message = "Welcome to Roost!"

    # Debug logging
    Rails.logger.debug "View Path: pages/home"
    Rails.logger.debug "Featured Spaces: #{@featured_spaces.inspect}"

    respond_to do |format|
      format.html
      format.json do
        render json: {
          featured_spaces: @featured_spaces.as_json(
            include: { building: { only: [:id, :name, :code] } }
          ),
          message: @message
        }
      end
    end
  end
end