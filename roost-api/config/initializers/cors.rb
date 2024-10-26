Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:4321' # Astro development server

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],
      credentials: true
  end
end
