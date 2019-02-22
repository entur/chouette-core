require Rails.root + 'config/middlewares/cachesettings'

Rails.application.configure do

  SmartEnv.set :RAILS_DB_PASSWORD, required: true
  SmartEnv.set :RAILS_HOST, default: 'http://front:3000'
  SmartEnv.set :IEV_URL, default: "http://iev:8080"

  # Settings specified here will take precedence over those in config/application.rb.

  config.eager_load = true

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Must add sub uri for controllers.
  # config.action_controller.relative_url_root = "/chouette2"

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  # config.serve_static_files = false
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
  # config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Must add sub uri for assets. Same as config.action_controller.relative_url_root
  # config.assets.prefix = "/chouette2"

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  # config.log_level = :info
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  config.logger = Logger.new(STDOUT)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store
  if SmartEnv['REDIS_URL']
    config.cache_store = :redis_store, SmartEnv['REDIS_URL'], { expires_in: 90.minutes }
  end

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.action_mailer.default_url_options = { :host => ENV.fetch('MAIL_HOST') } if ENV['MAIL_HOST']

  # Configure the e-mail address which will be shown in Devise::Maile
  config.mailer_sender = ENV.fetch('MAIL_FROM', "chouette@af83.com")
  config.action_mailer.delivery_method     = :letter_opener
  config.action_mailer.default_options = { from: ENV.fetch('MAIL_FROM', "chouette@af83.com") }
  config.action_mailer.smtp_settings = { address: ENV.fetch('SMTP_HOST') } if ENV['SMTP_HOST']
  config.action_mailer.asset_host    = ENV['MAIL_ASSETS_URL_BASE']

  # See #8823
  config.chouette_email_user = SmartEnv['CHOUETTE_EMAIL_USER']

  config.to_prepare do
    Devise::Mailer.layout "mailer"
  end

  config.accept_user_creation = ENV.fetch('ACCEPT_USER_CREATION','0')=='1'?true:false

  config.chouette_authentication_settings = JSON.parse(ENV.fetch('AUTH_SETTINGS','{
    "type": "database"
  }'),{symbolize_names: true})


  # paths for external resources
  config.to_prepare do
    Devise::Mailer.layout "mailer"
  end

  config.i18n.available_locales = [:fr, :en]

  config.middleware.insert_after Rack::Sendfile, CacheSettings, {
    /\/assets\/.*/ => {
      cache_control: "max-age=#{1.year.to_i}, public",
      expires: 1.year.to_i
    }
  }

  # Set node env for browserify-rails
  # config.browserify_rails.node_env = "production"
end
