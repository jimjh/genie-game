# This entire controller operates under the +current_user+ context.
class SettingsController < ApplicationController

  before_filter :authenticate_user!

  # TODO [github] make this work with private repos.

  # GET /settings/profile
  def profile
  end

  # GET /settings/repositories
  def repositories
    @repos, @lessons = github_repos, {}
    @last_sync = Rails.cache.read "#{github_repos_key}_last_mod"
    lessons = current_user.lessons.select([:url, :status, :id, :slug])
    lessons.each { |lesson| @lessons[lesson.url] = lesson }
  rescue Github::Error::ServiceError
    @repos = []
    flash[:error] = I18n.t('messages.settings.failures.github_service')
  end

  private

  # Gets list of repositories from GitHub and caches it.
  # @return [Array] hash objects
  def github_repos
    opts = { expires_in: 2.days, force: params[:sync].present? }
    Rails.cache.fetch github_repos_key, opts do
      Rails.cache.write "#{github_repos_key}_last_mod", Time.now
      auth = current_user.authorizations.find_by_provider('github') || not_found
      @client = Github.new auto_pagination: true, oauth_token: auth.token
      github_user_repos + github_org_repos
    end
  end

  def github_user_repos
    @client.repos.list.body
  end

  def github_org_repos
    @client.orgs.list.body.reduce([]) do |memo, org|
      memo + @client.repos.list(type: 'member', org: org.login).body
    end
  end

  # Constructs cache key for the current user.
  # @return [String] cache key for list of repositories
  def github_repos_key
    "github_repositories_for_user_#{current_user.id}"
  end

end
