source 'http://rubygems.org'
source 'https://rails-assets.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.9'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-sass-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# Sitemap
gem "sitemap_generator"

# API Rest
gem 'faraday', '~> 0.9.1'
gem 'faraday_middleware', '~> 0.9.1'
gem 'kleisli'

platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.3'
  gem 'jruby-openssl'
  gem "jruby-rack-worker"
  gem 'warbler'
  gem 'therubyrhino'
end

platforms :ruby do
  gem 'therubyracer', '~> 0.10.2'
  gem 'pg'
  gem 'sqlite3'
end

# I18n
gem 'rails-i18n', '~> 4.0.0'

# Authentication
gem 'devise', '~> 3.4.0'
gem 'devise-i18n'
gem 'devise-encryptable'
gem 'devise_invitable'

# Map, Geolocalization
gem "map_layers", "0.0.4"
gem "georuby-ext", "0.0.5"
gem "georuby", "2.3.0" # Fix version for georuby-ext because api has changed

# User interface
gem 'language_engine', '0.0.6'
gem 'calendar_helper', "0.2.5"
gem 'cocoon'
gem 'formtastic', "2.3.1"
gem 'RedCloth'

# Javascript
gem "modernizr-rails", "~> 2.0.6"
gem 'morrisjs-rails'
gem 'raphael-rails'

# Use twitter bootstrap resources
gem 'rails-assets-bootstrap-sass-official', '~> 3.3.0'
gem 'font-awesome-sass', '~> 4.2.0'
gem 'will_paginate-bootstrap'
gem 'simple_form', '~> 3.1.0'
gem 'rails-assets-tagmanager', '~> 3.0.1.0'
gem 'rails-assets-typeahead.js', '~> 0.10.5'
gem "breadcrumbs_on_rails"
gem 'rails-assets-typeahead.js-bootstrap3.less'
gem 'rails-assets-respond'
gem 'rails-assets-eonasdan-bootstrap-datetimepicker', '~> 3.1.3'
gem 'rails-assets-jquery-tokeninput', '~> 1.7.0'

# Format Output
gem 'json'
gem 'rubyzip', '~> 1.1.6'
gem 'roo'

# Controller
gem 'inherited_resources'
gem 'google-analytics-rails'

# Model
gem 'will_paginate', '~> 3.0', :git => "https://github.com/mislav/will_paginate.git"
gem 'ransack'
gem 'squeel'

gem 'ninoxe', :git => 'https://github.com/afimb/ninoxe.git', :branch => "rails4"
#gem 'ninoxe', :git => 'https://github.com/afimb/ninoxe.git'
#gem 'ninoxe',:path => '~/workspace/chouette/ninoxe'

gem 'acts_as_list', '~> 0.6.0'
gem "acts_as_tree", '~> 2.1.0', :require => "acts_as_tree"

gem 'rabl'

gem 'delayed_job_active_record'
gem 'apartment'

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rails-erd'
  gem 'meta_request'
end

group :test, :development do
  gem "rspec-rails", "~> 3.1.0"
  gem 'capybara', "~> 2.4.0"
  gem 'capybara-webkit'
  gem 'poltergeist'
  gem 'launchy'
  gem 'factory_girl_rails', '1.7'
  # gem 'i18n-tasks'
  gem 'rb-inotify', :require => RUBY_PLATFORM.include?('linux') && 'rb-inotify'
  gem 'rb-fsevent', :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
  gem 'transpec'
  gem 'database_cleaner'
end

group :production do
   gem "SyslogLogger"
   gem "daemons"
end


