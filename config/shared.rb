module Genie
  module SharedConstants

    HOST  = 'beta.geniehub.org'

    REDIS = { host: 'localhost', port: 6379 }
    REDIS_URL = "redis://#{REDIS[:host]}:#{REDIS[:port]}/0/cache"

  end
end
