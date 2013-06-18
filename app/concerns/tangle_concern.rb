require 'tangle/client'

# Modular concern for creating thread-singleton clients.
module TangleConcern

  def tangle_client
    Thread.current[:"#{self.class.name.underscore}_tangle_client"] ||=
      Tangle::Client.new Rails.application.config.tangle
  end

end
