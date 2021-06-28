require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

require 'adyen_cse'
require 'adyen-ruby-api-library'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AnkaChallenge
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.cse = AdyenCse::Encrypter.new(ENV['ADYEN_CLIENT_ENCRYPTION_KEY'])

    config.adyen = Adyen::Client.new
    config.adyen.env = ENV['ADYEN_ENV'].to_sym

    config.adyen.checkout.version = 67

    config.adyen.ws_user     = ENV['ADYEN_WS_USERNAME']
    config.adyen.ws_password = ENV['ADYEN_WS_PASSWORD']
    config.merchant_account  = ENV['ADYEN_MERCHANT_ACCOUNT']
  end
end
