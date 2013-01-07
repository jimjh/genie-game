class SettingsController < ApplicationController

  before_filter :authenticate_user!

  # TODO:   [github] make this work with private repos.
  # TODO:   [github] make this work with organization repos.
  # TODO:   cache the query results.
  # FIXME:  refactor into adapters for other git hosting services

  def index
    auth = current_user.authorizations.find_by_provider('github') || not_found
    # FIXME:  pagination, error handling
    @repos     = Github.new.repos.list user: auth.nickname
    @published = current_user.lessons.pluck(:url)
  end

end
