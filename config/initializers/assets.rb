# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire index your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and index non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w( home.css )
Rails.application.config.assets.precompile += %w( profile.css )

Rails.application.config.assets.precompile += %w( home.js )
Rails.application.config.assets.precompile += %w( profile.js )

Rails.application.config.assets.precompile += %w( pdf_styles.css.scss )