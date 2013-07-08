# Creates and verifies git hooks.
#
# Use {#create_hook_access_token} to generate a deterministic signature that
# can be added to the hook URL (e.g. as a HTTP Auth password). When the hook is
# invoked, verify the signature using {#verify_hook_access_token}.
#
# Use {#github_client} to create and cache a github client.
module GithubConcern
  extend self

  # Parameters sent to GitHub when creating the hook.
  HOOK_PARAMS = {
    name: 'web',
    config: { content_type: 'json' }
  }.freeze

  API_CONFIG = {
    auto_pagination: true
  }.freeze

  # @return [Github::Client] client
  def github_client(user = current_user)
    oauth = user.github_oauth!
    @github_client ||= begin
      Github.new API_CONFIG.merge(oauth_token: oauth.token)
    end
  end

  # @return [Boolean] true if signature is valid and matches expected params
  def verify_hook_access_token(token, github_login, repo_name)
    data = ::Base64.strict_encode64 Marshal.dump user: github_login, repo: repo_name
    hook_access_verifier.verify "#{data}--#{token}"
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    false
  else
    true
  end

  # @return [String] token for given github_login and repo_name
  def create_hook_access_token(github_login, repo_name)
    sig = hook_access_verifier.generate user: github_login, repo: repo_name
    sig.split('--')[1]
  end

  def hook_access_verifier
    @hook_access_verifier ||=
      ActiveSupport::MessageVerifier.new Rails.application.config.github[:password]
  end

  # Lazily adds {#push_lessons_url} to {HOOK_PARAMS}.
  # @return [Array] parameters suitable for +github_api+.
  def hook_params(github_login, repo_name)
    user     = Rails.application.config.github[:username]
    password = create_hook_access_token github_login, repo_name
    params   = HOOK_PARAMS.clone
    params[:config].merge! url: push_lessons_url(user: user, password: password)
    return github_login, repo_name, params
  end

end
