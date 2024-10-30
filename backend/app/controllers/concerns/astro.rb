# app/controllers/concerns/astro.rb
module Astro
  extend ActiveSupport::Concern

  included do
    around_action :handle_astro_response

    rescue_from(ActionController::MissingExactTemplate) do |_exception|
      action = params[:action]
      controller = controller_name
      
      # Get instance variables that are not part of the controller's state
      props = instance_variables.select { |v| 
        !v.to_s.start_with?('@_') && 
        v.to_s != '@rendered_format' && 
        v.to_s != '@marked_for_same_origin_verification' 
      }
      
      # Convert instance variables to a hash
      props_hash = props.map { |v| [v.to_s[1..-1], instance_variable_get(v)] }.to_h
      
      # Set the Astro view header with the correct path
      response.headers['X-Astro-View'] = "#{controller}/#{action}"
      
      # Return JSON with correct content type
      render json: props_hash, content_type: 'application/json'
    end

    before_action do
      # Ensure we're setting JSON content type for XHR requests
      if request.xhr?
        request.format = :json
      end
    end
  end

  private

  def handle_astro_response
    # Set format to JSON for Astro requests
    request.format = :json if request.headers['X-Requested-With'] == 'XMLHttpRequest'

    # Execute the action
    yield

    # After action, if no response body was set and we have instance variables
    if response.body.blank? && request.format.json?
      # Get instance variables that we want to pass to the view
      props = instance_variables.select { |v| 
        !v.to_s.start_with?('@_') && 
        v.to_s != '@rendered_format' && 
        v.to_s != '@marked_for_same_origin_verification' 
      }
      
      # Convert instance variables to a hash
      props_hash = props.map { |v| [v.to_s[1..-1], instance_variable_get(v)] }.to_h

      # Set Astro view header
      response.headers['X-Astro-View'] = "#{controller_name}/#{action_name}"
      
      # Render JSON response
      render json: props_hash
    end
  end
end