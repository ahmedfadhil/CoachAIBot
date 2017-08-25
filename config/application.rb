require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Coach
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Changing schema for ActiveRecord
    config.active_record.schema_format = :sql

    # Autoload customized modules from /lib
    config.autoload_paths += %W(#{config.root}/lib)

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
