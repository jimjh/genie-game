require 'bundler/capistrano'
require 'capistrano/maintenance'
require File.expand_path('../shared', __FILE__)

set :application, 'genie-game'
set :repository,  'git@github.com:jimjh/genie-game.git'
set :user,        'passenger'
set :default_shell, '/bin/bash -l'

# no idea what this does - could be wrong
set :normalize_asset_timestamps, false

set :scm,        :git
set :deploy_via, :remote_cache # don't re-clone every time
set :use_sudo,   false

set :keep_releases, 5

set :maintenance_config_warning, false

role :web, Genie::SharedConstants::HOST
role :app, Genie::SharedConstants::HOST
role :db,  Genie::SharedConstants::HOST, primary: true

before 'deploy:update',    'deploy:web:disable'
before 'deploy:restart',   'deploy:migrate'
after  'deploy:restart',   'deploy:cleanup'
after  'deploy:restart',   'deploy:web:enable'

before 'deploy:assets:precompile', 'deploy:secrets'
after  'deploy:assets:precompile', 'deploy:clean_expired' # for turbo-sprockets

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do; end
  task :stop do; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :load_schema, :roles => :db do
    run "cd #{current_path}; bundle exec rake RAILS_ENV=production db:schema:load"
  end
  task :secrets do
    run "ln -fs -- #{shared_path}/config/application.yml #{release_path}/config"
  end
  task :clean_expired do
    run "cd #{release_path}; bundle exec rake RAILS_ENV=production RAILS_GROUPS=assets assets:clean_expired"
  end
end
