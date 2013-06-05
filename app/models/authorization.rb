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

  # attributes ---------------------------------------------------------------
  attr_accessible :link, :name, :nickname, :provider, :secret, :token, :uid
  attr_readonly :user_id

  # relationships ------------------------------------------------------------
  belongs_to :user, inverse_of: :authorizations

  # validations --------------------------------------------------------------
  validates_presence_of  :provider, :uid, :user, :token, :nickname

end
