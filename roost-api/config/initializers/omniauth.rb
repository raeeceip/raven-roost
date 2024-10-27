require 'omniauth/strategies/google_oauth2'

OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true