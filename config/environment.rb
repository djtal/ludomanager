# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present

RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [ :active_resource, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug
  
  
  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  #config.active_record.observers = :game_observer

  config.time_zone = 'UTC'
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :fr
  
  # See Rails::Configuration for more options
  config.gem "searchlogic"
  config.gem 'mislav-will_paginate', :version => '~> 2.3.11', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem "thoughtbot-paperclip", :lib => "paperclip", :source => "http://gems.github.com", :version => '2.3.0'
  config.gem "newrelic_rpm"
  
end



