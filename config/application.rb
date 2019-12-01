# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DexRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.eager_load_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('lib')

    redis_connected = begin
                        !!Sidekiq.redis(&:info)
                      rescue StandardError
                        false
                      end
    unless redis_connected
      raise 'No redis connection, run `bundle exec sidekiq`'
    end

    # config.active_job.queue_adapter = :sidekiq
    config.active_job.queue_adapter = ENV.fetch('QUEUE_ADAPTER', 'sidekiq')

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
