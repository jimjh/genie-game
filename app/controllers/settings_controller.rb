# This entire controller operates under the +current_user+ context.
class SettingsController < ApplicationController

  before_filter :authenticate_user!

  # TODO:   [github] make this work with private repos.
  # TODO:   [github] make this work with organization repos.

  def profile
  end

  def repositories
    @repos = github_repos
    lessons, @lessons = current_user.lessons.select([:url, :status]), {}
    lessons.each { |lesson| @lessons[lesson.url] = lesson.status }
  end

  private

  # Get list of repositories from GitHub and cache it.
  def github_repos
    page = params[:page] || 1
    key  = "github_repositories_for_user_#{current_user.id}_on_page_#{page}"
    opts = { expires_in: 2.days, force: params[:sync].present? }
    Rails.cache.fetch key, opts do
      auth = current_user.authorizations.find_by_provider('github') || not_found
      Github.repos.list(user: auth.nickname, page: page).body
    end
  end

end
