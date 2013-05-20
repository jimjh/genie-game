Genie::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes     = false
  config.allow_concurrency = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Redis for caching (port chosen by foreman)
  config.cache_store = :redis_store, "redis://localhost:3000/0/cache"

  # Used to construct a web hook for GitHub
  PORT = 3100
  HOST = 'localhost'
  Rails.application.routes.default_url_options[:host] = "#{HOST}:#{PORT}"

  # ActionMailer
  ADMIN_EMAIL_FROM  = ''
  PHONY_VIA_OPTIONS = {
    address: 'smtp.gmail.com',
    port: '587',
    enable_starttls_auto: true,
    user_name: '',
    password: '',
    authentication: 'plain',
    domain: 'localhost.localdomain'
  }
  config.action_mailer.perform_delivery      = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options   = { host: "#{HOST}:#{PORT}" }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.faye   = { url: "http://#{HOST}:3300/socket" }

  # Output paths for Lamp.
  config.lamp = {
    ips:           %w(127.0.0.1 0.0.0.0),
    client: {
      'host' => 'localhost',
      'port' => 3200 # chosen by foreman
    }
  }

end
