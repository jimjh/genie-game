#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Genie::Application.load_tasks

namespace :previewer do

  namespace :update do

    INPUT   = Pathname.new 'app/assets'
    OUTPUT  = Pathname.new '../genie-previewer/public/assets'

    desc 'Update javascript assets'
    task :js do
      input = INPUT + 'javascripts'
      exec <<-eos
        coffee -j #{OUTPUT + 'app.js'} -c #{input + 'verify.js.coffee'}
        uglifyjs --output #{OUTPUT + 'app.min.js'} #{OUTPUT + 'app.js'}
      eos
    end

    desc 'Update css assets'
    task :css do
      exec <<-eos
        compass compile -e production --force --css-dir #{OUTPUT}
      eos
    end

    task :all => %w(update:css update:js).map(&:to_sym)

  end

end
