# This entire controller operates under the +current_user+ context.
class SettingsController < ApplicationController

  before_filter :authenticate_user!

  # TODO:   [github] make this work with private repos.
  # TODO:   [github] make this work with organization repos.

  def profile
  end

  def repositories
    @repos = github_repos
    @last_sync = Rails.cache.read "#{github_repos_key}_last_mod"
    lessons, @lessons = current_user.lessons.select([:url, :status]), {}
    lessons.each { |lesson| @lessons[lesson.url] = lesson.status }
  end

  private

  # Get list of repositories from GitHub and cache it.
  # @return [Array] hash objects
  def github_repos
    opts = { expires_in: 2.days, force: params[:sync].present? }
    Rails.cache.fetch github_repos_key, opts do
      Rails.cache.write "#{github_repos_key}_last_mod", Time.now
      auth = current_user.authorizations.find_by_provider('github') || not_found
      Github.repos.list(user: auth.nickname, auto_pagination: true).body
    end
  end

  # @return [String] cache key for list of repositories
  def github_repos_key
    "github_repositories_for_user_#{current_user.id}"
  end

end
