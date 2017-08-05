source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Authentication solution
gem 'devise'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.1'

# Use Puma as the app server
gem 'puma', '~> 3.7'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
#gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'



# gem 'redis', '~> 3.0'                         # Use Redis adapter to run Action Cable in production
# gem 'bcrypt', '~> 3.1.7'                      # Use ActiveModel has_secure_password
# gem 'capistrano-rails', group: :development   # Use Capistrano for deployment

# Telegram API
gem 'telegram-bot-ruby'

# chatscript wrapper
gem 'chatscript'

# very usefull for hash dot notation
gem 'hash_dot'


source 'https://rails-assets.org' do
  gem 'rails-assets-eq.js'
  gem 'rails-assets-jquery'
  gem 'rails-assets-material-design-lite'
  gem 'rails-assets-mdl-selectfield'
  gem 'rails-assets-polyfills'
end

group :development, :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'selenium-webdriver'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'

  gem 'rails-erd'
  gem 'yaml_db'
end

group :production do
  # Heroku requests postgres for deploy
  gem 'pg','0.17.1'
  # Used by heroku to serve static assets and css stylesheets
  gem 'rails_12factor', '0.0.2'
end

# use this in production
# gem 'weight_diary', git: 'git@github.com:stoffie/ror-weight-diarty.git'
# use this to test local changes
gem 'weight_diary', path: '../weight_diary'
