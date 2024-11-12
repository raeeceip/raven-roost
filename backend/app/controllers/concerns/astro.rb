module Astro
  extend ActiveSupport::Concern

  included do
    around_action :handle_astro_response
  end

  private

  def handle_astro_response
    if request.headers['X-Requested-With'] == 'XMLHttpRequest'
      request.format = :json
      # Set content type explicitly
      response.headers['Content-Type'] = 'application/json'
    end

    yield

    if request.format.json? && !performed?
      props = if instance_variable_defined?(:@props)
        @props
      else
        instance_variables
          .reject { |v| v.to_s.start_with?('@_') }
          .each_with_object({}) do |var, hash|
            hash[var.to_s[1..-1]] = instance_variable_get(var)
          end
      end

      Rails.logger.debug "Astro Response Headers: #{response.headers.to_h}"
      Rails.logger.debug "Astro Props: #{props.inspect}"

      render json: props
    end
  end

  def set_astro_view(view_path)
    response.headers['X-Astro-View'] = view_path
  end
end