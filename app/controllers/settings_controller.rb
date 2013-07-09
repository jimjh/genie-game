# This entire controller operates under the +current_user+ context.
class SettingsController < ApplicationController
  include GithubConcern

  before_filter :authenticate_user!

  # GET /settings/repositories
  def repositories
    @repos, @lessons = github_repos, {}
    @last_sync = Rails.cache.read "#{github_repos_key}_last_mod"
    lessons = current_user.lessons.select([:url, :status, :id, :slug])
    @publish_count = lessons.inject(0) { |memo, v| v.published? ? memo + 1 : memo }
    lessons.each { |lesson| @lessons[lesson.url] = lesson }
  rescue Github::Error::ServiceError
    @repos = []
    flash[:error] = I18n.t('messages.settings.failures.github_service')
  end

  # GET /settings/authorizations
  def authorizations
    @sent_requests = current_user.sent_access_requests
    @received_requests = current_user.received_access_requests
  end

  private

  # Gets list of repositories from GitHub and caches it.
  # @return [Array] hash objects
  def github_repos
    opts = { expires_in: 2.days, force: params[:sync].present? }
    Rails.cache.fetch github_repos_key, opts do
      Rails.cache.write "#{github_repos_key}_last_mod", Time.now
      github_user_repos + github_org_repos
    end
  end

  def github_missing_manifest?(repo)
    begin
      github_client.repos.contents.get repo.owner.login, repo.name, 'manifest.yml'
    rescue Github::Error::ServiceError
      true
    else
      false
    end
  end

  def github_user_repos
    github_client.repos.list.body.reject(&method(:github_missing_manifest?))
  end

  def github_org_repos
    filter = method(:github_missing_manifest?)
    github_client.orgs.list.body.reduce([]) do |memo, org|
      repos = github_client.repos.list(type: 'member', org: org.login).body
      memo + repos.reject(&filter)
    end
  end

  # Constructs cache key for the current user.
  # @return [String] cache key for list of repositories
  def github_repos_key
    "github_repositories_for_user_#{current_user.id}"
  end

end
