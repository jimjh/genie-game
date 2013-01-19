glob = File.join File.dirname(__FILE__), 'locals.d', '*.rb'
Dir[glob].each { |file| load file }
