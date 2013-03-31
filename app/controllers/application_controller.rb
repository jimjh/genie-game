class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :protect_closed_beta # TODO: remove
  BETA_SECRET = 'ZcoxRINDmWhc6BH3XHQc'

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def bad_request
    head :bad_request
  end

  private

  def redirect_to_launchrock
    redirect_to 'http://signup.geniehub.org'
  end

  def protect_closed_beta
    redirect_to_launchrock if Rails.env.production? and cookies[:beta] != BETA_SECRET
  end

end
