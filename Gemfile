source 'https://rubygems.org'

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

gem 'rails', '~> 3.2.13'

group :assets do
  gem 'sass-rails',       '~> 3.2'
  gem 'coffee-rails',     '~> 3.2'
  gem 'compass-rails',    '~> 1.0'
  gem 'zurb-foundation',  '~> 4.0'
  gem 'uglifier',         '>= 1.0'
  gem 'turbo-sprockets-rails3'
end

group :test do
  gem 'no_peeping_toms',    '~> 2.1'
  gem 'faker',              '~> 1.1'
  gem 'mocha',              '~> 0.10', require: false
  gem 'shoulda',            '~> 3.3'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'simplecov',          '~> 0.7',  require: false
  gem 'database_cleaner'
  gem 'capybara'
  gem 'capybara-webkit'
end

group :development do
  gem 'rvm-capistrano', '~> 1.2',  require: false
  gem 'capistrano',     '~> 2.14', require: false
  gem 'foreman',        '~> 0.61', require: false
  gem 'capistrano-maintenance', '0.0.3', require: false
end

group :test, :development do
  gem 'sqlite3'
  gem 'debugger-pry'
  gem 'brakeman'
  gem 'rspec-rails', '~> 2.12'
  gem 'debugger',    '~> 1.3'
  gem 'pry',         '~> 0.9'
  gem 'hirb',        '~> 0.7'
end

group :production do
  gem 'pg',   '~> 0.14.1'
end

gem 'jquery-rails', '~> 2.2'
gem 'redis-rails',  '~> 3.2'
gem 'thin', '~> 1.5'
gem 'haml', '~> 4.0'

# Authentication
gem 'devise',           '~> 2.2'
gem 'omniauth',         '~> 1.1'
gem 'omniauth-github',  '~> 1.0'

gem 'simple_form',         '~> 2.0'
gem 'friendly_id',         '~> 4.0'

# GitHub Adapter
gem 'github_api',   '~> 0.8'

# WebSockets
gem 'faye',         '~> 0.8'
gem 'faye-redis',   '~> 0.1', require: false

gem 'lamp', git: 'git@github.com:jimjh/genie-compiler.git',
  branch: 'master', require: false
gem 'spirit', git: 'git@github.com:jimjh/genie-parser.git',
  branch: 'master', require: false
