source 'https://rubygems.org'

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

gem 'rails', '~> 3.2.12'
gem 'sqlite3'

group :assets do
  gem 'sass-rails',       '~> 3.2.3'
  gem 'coffee-rails',     '~> 3.2.1'
  gem 'compass-rails',    '~> 1.0.3'
  gem 'zurb-foundation',  '~> 4.0.8'
  gem 'uglifier',         '>= 1.0.3'
end

group :test do
  gem 'no_peeping_toms',    '~> 2.1.3'
  gem 'faker',              '~> 1.1.2'
  gem 'mocha',              '~> 0.10',  require: false
  gem 'cucumber-rails',     '~> 1.3.0', require: false
  gem 'database_cleaner',   '~> 0.9.1'
  gem 'shoulda',            '~> 3.3.2'
  gem 'factory_girl_rails', '~> 4.0'
end

group :development do
  gem 'rvm-capistrano'
  gem 'capistrano'
  gem 'foreman',      '~> 0.61.0'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.12.2'
  gem 'debugger',    '~> 1.3.1'
  gem 'pry',         '~> 0.9.12'
  gem 'hirb',        '~> 0.7.1'
end

group :production do
  gem 'pg',   '~> 0.14.1'
end

gem 'jquery-rails', '~> 2.2.1'
gem 'thin', '~> 1.5.0'
gem 'haml', '~> 4.0.0'
gem 'redis-rails', '~> 3.2.3'

# Authentication
gem 'devise',           '~> 2.2.3'
gem 'omniauth',         '~> 1.1.3'
gem 'omniauth-github',  '~> 1.0.3'
gem 'simple_form',      '~> 2.0.4'
gem 'friendly_id',      '~> 4.0.1'

# GitHub Adapter
gem 'github_api',   '~> 0.8.6'

# WebSockets
gem 'faye',         '~> 0.8.9'
gem 'faye-redis',   '~> 0.1.0', require: false

gem 'lamp', git: 'git@github.com:jimjh/genie-compiler.git',
  branch: 'master', require: false
gem 'spirit', git: 'git@github.com:jimjh/genie-parser.git',
  branch: 'master', require: false
gem 'aladdin', git: 'git@github.com:jimjh/genie-previewer.git',
  branch: 'master', require: false
