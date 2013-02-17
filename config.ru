# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if Rails.env.production?
  # FIXME: probably should launch independently in production for scalability.
  puts "ERROR: faye deployment has not been resolved."
  exit 1
else
  Faye::WebSocket.load_adapter 'thin'
  use Faye::RackAdapter, mount: '/faye', timeout: 25
end

run Genie::Application
