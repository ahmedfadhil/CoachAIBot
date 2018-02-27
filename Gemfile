ruby '2.4.0'

source 'https://rubygems.org'
source 'https://rails-assets.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# use svg files in views
#gem 'inline_svg'

# finite state machine for user <-> bot interaction
# gem 'state_machines'
gem 'aasm', '~> 4.12', '>= 4.12.3'

gem 'record_tag_helper', '~> 1.0'

# writing and deploying cron jobs.
# gem 'whenever', :require => false

# another way for cron jobs
gem 'crono'
gem 'daemons' #used by crono

# cron jobs web ui
gem 'haml'
gem 'sinatra', require: nil

gem 'time_difference'

# use Trailblazer::Cell
gem 'cells'
gem 'cells-rails'
gem 'cells-erb'

# calculate percentages
gem 'percentage'

# pdf from html
gem 'wicked_pdf'

# wicked_pdf is a wrapper for wkhtmltopdf, I need to install that, too
gem 'wkhtmltopdf-binary-edge'
#gem 'wkhtmltopdf-binary'

# pdf creator
gem 'prawn', '~> 2.2', '>= 2.2.2'

# highcharts & highstock
#gem 'highcharts-rails'
gem 'highstock-rails'

# jquery-UI
gem 'jquery-ui-rails'

# for polling service in notification task
gem 'polling'

# some pretty print
gem 'awesome_print'

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
gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'


# gem 'redis', '~> 3.0'                         # Use Redis adapter to run Action Cable in production
# gem 'bcrypt', '~> 3.1.7'                      # Use ActiveModel has_secure_password
# gem 'capistrano-rails', group: :development   # Use Capistrano for deployment

# API.AI wrapper
gem 'api-ai-ruby'

# Telegram API
gem 'telegram-bot-ruby'

# chatscript wrapper
gem 'chatscript'

# very usefull for hash dot notation
gem 'hash_dot'

# oauth2 client
gem 'oauth2'

####
gem 'rails-assets-eq.js'
gem 'rails-assets-jquery'
#gem 'rails-assets-material-design-lite'
gem 'material_design_lite-rails', '~> 1.3'
gem 'rails-assets-mdl-selectfield'
gem 'rails-assets-polyfills'

group :development, :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'selenium-webdriver'
  # Use sqlite3 as the database for Active Record
  #gem 'sqlite3'
  gem 'pg', '0.20.0'
  gem 'railroady'
end

group :development do
	gem 'rails-erd'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  
  # Refactoring classes names
   gem 'rails_refactor', '~> 1.3'

	# Deploy without confidence ®
	gem "capistrano", "~> 3.9"
	gem 'capistrano-rails'
  gem 'capistrano-rbenv'
	gem 'capistrano-passenger'

  gem 'rack-mini-profiler', require: false
  # For memory profiling (requires Ruby MRI 2.1+)
  gem 'memory_profiler'

  # For call-stack profiling flamegraphs (requires Ruby MRI 2.0.0+)
  gem 'flamegraph'
  gem 'stackprof'     # For Ruby MRI 2.1+
end

group :production do
  # Heroku requests postgres for deploy
  gem 'pg', '0.20.0'
  # Used by heroku to serve static assets and css stylesheets
  gem 'rails_12factor', '0.0.2'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]