module HookConcern
  extend self

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

end
