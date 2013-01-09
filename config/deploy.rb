require 'rvm/capistrano'
require 'bundler/capistrano'

set :application, 'genie-game'
set :repository,  'git@github.com:jimjh/genie-game.git'
set :user,        'passenger'

# no idea what this does - could be wrong
set :normalize_asset_timestamps, false

set :scm, :git

# force cap to use rvm
set :rvm_ruby_string, '1.9.3'

role :web, 'ec2-54-245-18-137.us-west-2.compute.amazonaws.com'                   # Your HTTP server, Apache/etc
role :app, 'ec2-54-245-18-137.us-west-2.compute.amazonaws.com'                   # This may be the same as your `Web` server
role :db,  'ec2-54-245-18-137.us-west-2.compute.amazonaws.com', :primary => true # This is where Rails migrations will run

after 'deploy:restart', 'deploy:cleanup'

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
