# config/initializers/json_param_key_transform.rb
ActionDispatch::Request.parameter_parsers[:json] = lambda { |raw_post|
  data = ActiveSupport::JSON.decode(raw_post)
  if data.is_a?(Array)
    data.map { |item| item.deep_transform_keys!(&:underscore) }
  else
    data.deep_transform_keys!(&:underscore)
  end
}

# config/initializers/mime_types.rb
# Add this if it's not already there
Mime::Type.register "application/json", :json, %w( text/x-json application/jsonrequest )