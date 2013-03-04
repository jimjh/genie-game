# Modular Concern for creating thread-singleton clients.
module FayeConcern

  include FayeHelper

  # @return [Faye::Client] faye client on this thread
  def faye_client
    name = "#{self.class.name.underscore}_faye_client".to_sym
    Thread.current[name] ||= begin
      Faye::Client.new Rails.application.config.faye[:url]
    end
  end

end
