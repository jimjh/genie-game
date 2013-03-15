require 'faye'
require 'faye/redis'
Faye::WebSocket.load_adapter('thin')

run Faye::RackAdapter.new(
  mount: '/socket',
  timeout: 25,
  engine: {
    type: Faye::Redis,
    host: 'localhost',
    port: 3000
  }
)
