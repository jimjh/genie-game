require 'uuidtools'
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # TODO: I18n strings

  rescue_from ActiveRecord::RecordInvalid do |invalid|
    logger.warn invalid.record.errors
    # TODO
  end

  # GET /users/auth/github/callbacks
  def github
    oauthorize 'GitHub'
  end

  def passthru
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false
  end

  private

  def oauthorize(kind)
    @user = find_for_oauth kind, env['omniauth.auth'], current_user
    flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: kind
    session["devise.#{kind.downcase}_data"] = env['omniauth.auth']
    sign_in_and_redirect @user, event: :authentication
  end

  def find_for_oauth(provider, access_token, resource=nil)

    uid, auth_attr, name = access_token['uid'], { provider: provider }, access_token['info']['name']
    case provider
    when 'GitHub'
      auth_attr.merge! uid: uid,
        token:  access_token['credentials']['token'],
        name:   name,
        link:   access_token['extra']['raw_info']['html_url']
    else raise "Provider #{provider} not handled."
    end

    nickname = access_token['info']['nickname']

    user = resource || find_by_uid(provider, uid) || register(name, nickname)
    auth = user.authorizations.find_by_provider(provider) || user.authorizations.build(auth_attr)
    auth.update_attributes! auth_attr

    user

  end

  # Looks for a user with the given provider and provider's user ID.
  # @return [User] user
  def find_by_uid(provider, uid)
    user = Authorization.find_by_provider_and_uid(provider, uid.to_s).try(:user)
  end

  # Registers new user.
  # @return [User] user
  def register(name, nickname)
    user = User.new name: name, nickname: nickname
    user.save!
    user
  end

end
