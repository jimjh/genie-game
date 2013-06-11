namespace :previewer do

  namespace :update do

    INPUT   = Rails.root.join('app/assets/javascripts')
    OUTPUT  = Rails.root.join('../genie-previewer/public/assets')

    desc 'Update javascript assets'
    task :js do
      scripts = Dir[INPUT.join('*.js.coffee')].to_a
      exec <<-eos
        coffee -j #{OUTPUT + 'app.js'} -c #{scripts.join ' '}
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
