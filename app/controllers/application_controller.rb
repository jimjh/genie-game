class ApplicationController < ActionController::Base

  protect_from_forgery

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def bad_request
    head :bad_request
  end

  private

end
