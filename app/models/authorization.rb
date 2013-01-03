class Authorization < ActiveRecord::Base

  attr_accessible :link, :name, :nickname, :provider, :secret, :token, :uid

  # relationships ------------------------------------------------------------
  belongs_to :user

  # validations --------------------------------------------------------------
  validates_presence_of :provider, :uid, :user_id, :token
  validate              :user_must_exist

  private

  def user_must_exist
    user_id.nil? || User.find(user_id)
  rescue ActiveRecord::RecordNotFound
    errors.add :user, 'is not a registered user.'
  end

end
