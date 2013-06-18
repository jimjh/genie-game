require 'lamp/rpc/client'

# Modular concern for creating thread-singleton clients.
module LampConcern

  # @return [Lamp::Client] lamp client on this thread.
  def lamp_client
    Thread.current[:"#{self.class.name.underscore}_lamp_client"] ||=
      Lamp::RPC::Client.new Rails.application.config.lamp[:client]
  end

end
