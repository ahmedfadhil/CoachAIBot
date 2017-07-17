require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Coach
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.active_record.schema_format = :sql

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- index .rb files in that directory are automatically loaded.

    # Setting Devise layout
    config.to_prepare do
      Devise::SessionsController.layout 'home'
      Devise::UnlocksController.layout 'home'
      Devise::PasswordsController.layout 'home'
    end
  end
end
