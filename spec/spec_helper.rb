ENV['RAILS_ENV'] = 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|

  config.mock_with :mocha

  config.use_transactional_fixtures                 = false
  config.infer_base_class_for_anonymous_controllers = false

  config.order = 'random'

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true

  config.include Test::Matchers,            type: :model

  config.include Devise::TestHelpers,       type: :controller
  config.include Test::ControllerHelpers,   type: :controller

  config.include Features::SessionHelpers,    type: :feature
  config.include Features::I18nHelpers,       type: :feature
  config.include Features::SimpleFormHelpers, type: :feature

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, truncate: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) { DatabaseCleaner.start }
  config.after(:each)  { DatabaseCleaner.clean }

end

OmniAuth.config.test_mode = true
ActiveRecord::Observer.disable_observers
Capybara.javascript_driver = :webkit
