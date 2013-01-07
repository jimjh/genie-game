# == Authorization
# Used with OmniAuth to remember a user's authorized providers.
# - +link+ should be a URL to the user's profile at the provider (optional)
# - +name+ is the user's full name
# - +nickname+ is the user's user name
# - +provider+ is the provider of this authorization (note that 'GitHub' and
#   'github' are different.)
# - +secret+ is ?? (optional)
# - +token+ is the OAuth token given by the provider during the callback
# - +uid+ is the user's primary key at the provider
class Authorization < ActiveRecord::Base

  attr_accessible :link, :name, :nickname, :provider, :secret, :token, :uid

  # relationships ------------------------------------------------------------
  belongs_to :user

  # validations --------------------------------------------------------------
  validates_presence_of :provider, :uid, :user_id, :token, :nickname
  validate              :user_must_exist

  private

  def user_must_exist
    user_id.present? && User.find(user_id)
  rescue ActiveRecord::RecordNotFound
    errors.add :user, 'is not a registered user.'
  end

end
