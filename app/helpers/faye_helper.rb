# Helper for generating url used by Faye and generating channel paths. In
# general, we want to mirror Rails routes, but there might be some additional
# ones that we need.
module FayeHelper

  # @return [String] absolute path to faye server.
  def faye_url
    Rails.application.config.faye[:url]
  end

end
