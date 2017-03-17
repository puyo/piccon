# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] = 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_piccon',
    :secret      => '89a5fcd4d35a9ab4cec991197537446e9c883a83883b43e0307314d445083299cc9b588309bdf6ba1e122deefbc01808b85c62b4acfb7969eae51d7cdcb2e114'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Rails 2.0 forgery protection doesn't work with Facebook apps.
  config.action_controller.allow_forgery_protection = false

  config.gem 'rmagick', :version => '>=2.5.1', :lib => 'RMagick'
  config.gem 'rfacebook', :version => '>=0.9.8'

  config.action_controller.optimise_named_routes = false
end

# lib
require 'rfacebook_patches'

ExceptionNotifier.exception_recipients = %w(blue.puyo+picconerrors@gmail.com lucyding+picconerrors@gmail.com)
ExceptionNotifier.sender_address = %("Piccon" <pictorial.consequences@gmail.com>)
ExceptionNotifier.email_prefix = '[PICCON] '

ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => 587,
  :domain => "hopefullyfun.com",
  :authentication => :plain,
  :user_name => "pictorial.consequences",
  :password => ENV['GMAIL_PASSWORD'],
}
