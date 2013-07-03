module Genie
  module SharedConstants

    HOST    = 'beta.geniehub.org'

    # Amazon Private IP, used to authenticate compiler
    IP    = '10.164.25.226'

    REDIS =  { host: 'localhost', port: 6379 }
    REDIS_URL = "redis://#{REDIS[:host]}:#{REDIS[:port]}/0/cache"

  end
end
