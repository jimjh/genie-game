module Genie
  module SharedConstants

    #HOST  = 'ec2-54-225-0-30.compute-1.amazonaws.com'
    HOST  = 'beta.geniehub.org'
    # Amazon Private IP, used to authenticate compiler
    IP    = '10.245.214.58'

    REDIS =  { host: 'localhost', port: 6379 }
    REDIS_URL = "redis://#{REDIS[:host]}:#{REDIS[:port]}/0/cache"

  end
end
