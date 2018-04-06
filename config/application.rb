require_relative 'boot'

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Coach
  class Application < Rails::Application
    # Re/Enable the autoload functionality for all environments:
    # COULD BECAME DEPRECATED IN FUTURE VERSIONS OF Rails
    # config.enable_dependency_loading = true

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Setting Application timezone
    config.time_zone = 'Rome'.freeze

    # Setting ActiveRecord timezone
    config.active_record.default_timezone = :local

    # Changing schema for ActiveRecord
    config.active_record.schema_format = :ruby

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

    config.cells.with_assets = ['profile_header_cell']

    # Load Cell classes when pre compiling classes
    config.assets.initialize_on_precompile = true

    # Add vendors paths to assets in order to easily include them to application.js or .css
    config.assets.paths << Rails.root.join('vendor')

    config.i18n.default_locale = :it
    # Custom error page
    config.exceptions_app = self.routes
  end


end

