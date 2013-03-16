require 'faye'
require 'faye/redis'
require File.expand_path('../config/shared', __FILE__)

Faye::WebSocket.load_adapter('thin')

@config = {
  mount: '/socket',
  timeout: 25,
  engine: { type: Faye::Redis }
}

case ENV['RACK_ENV']
when 'production'
  @config[:engine].merge! Genie::SharedConstants::REDIS
else
  @config[:engine].merge! host: 'localhost', port: 3000
end

run Faye::RackAdapter.new @config
