ENV['ELASTICSEARCH_URL'] = ENV.fetch('ELASTICSEARCH_URL', 'http://localhost:9200')

if Rails.env.development?
  logger = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = proc { |severity, datetime, progname, msg| "\n#{msg}\n" }
  Searchkick.client.transport.logger = logger
end
