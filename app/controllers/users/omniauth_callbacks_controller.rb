class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # GET /users/auth/github/callbacks
  def github
    oauthorize 'github'
  end

  def passthru
    not_found
  end

  def after_omniauth_failure_path_for(scope)
    root_path
  end

  private

  def oauthorize(kind)
    @user = find_for_oauth kind, request.env['omniauth.auth'], current_user
    flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: kind
    sign_in_and_redirect @user, event: :authentication
    session["devise.#{kind.downcase}_data"] = request.env['omniauth.auth']
  end

  # @note This should be refactored at some point for better error handling and
  #   validation of the +auth+ parameter. At this point, if certain
  #   crucial fields don't exist, it will either raise some error regarding
  #   nils or {ActiveRecord::RecordInvalid}. Either case should redirect the
  #   user to a 500 page.
  def find_for_oauth(provider, auth, resource=nil)

    uid, auth_attr = auth.uid, { provider: provider }
    name, nickname = auth.info.name, auth.info.nickname
    token, email   = auth.credentials.token, auth.info.email

    case provider
    when 'github'
      auth_attr.merge! uid: uid, token: token, name: name, nickname: nickname,
        link: auth.extra.raw_info.html_url, email: email
    else raise "Provider #{provider} not handled."
    end

    user = resource || find_by_uid(provider, uid) || User.register!(nickname)
    authorization = user.authorizations.find_by_provider(provider) || user.authorizations.build(auth_attr)
    authorization.update_attributes! auth_attr

    user

  end

  # Looks for a user with the given provider and provider's user ID.
  # @param  [String] provider             OAuth provider
  # @param  [String] uid                  provider's user ID
  # @return [User]   user
  def find_by_uid(provider, uid)
    Authorization.find_by_provider_and_uid(provider, uid.to_s).try(:user)
  end

end
