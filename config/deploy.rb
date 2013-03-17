require 'rvm/capistrano'
require 'bundler/capistrano'
require File.expand_path('../shared', __FILE__)

set :application, 'genie-game'
set :repository,  'git@github.com:jimjh/genie-game.git'
set :user,        'passenger'

# no idea what this does - could be wrong
set :normalize_asset_timestamps, false

set :scm,        :git
set :deploy_via, :remote_cache # don't re-clone every time
set :use_sudo,   false

# force cap to use rvm
set :rvm_ruby_string, 'ruby-1.9.3-p362'
set :rvm_type,        :system

role :web, Genie::SharedConstants::HOST          # Your HTTP server, Apache/etc
role :app, Genie::SharedConstants::HOST          # This may be the same as your `Web` server
role :db,  Genie::SharedConstants::HOST, primary: true # This is where Rails migrations will run

after 'deploy:restart',  'deploy:cleanup'
after 'deploy:update',   'deploy:migrate'

before 'deploy:assets:precompile', 'deploy:secrets'
after  'deploy:assets:precompile', 'deploy:clean_expired' # for turbo-sprockets

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do; end
  task :stop do; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :load_schema do
    run "cd #{current_path}; bundle exec rake RAILS_ENV=production db:schema:load"
  end
  task :secrets do
    run "ln -fs -- #{shared_path}/config/locals.d #{release_path}/config/environments"
  end
  task :clean_expired do
    run "cd #{release_path}; bundle exec rake assets:clean_expired"
  end
end
