class User < ActiveRecord::Base
  extend FriendlyId

  devise :rememberable, :trackable, :token_authenticatable, :omniauthable
  friendly_id :nickname, use: :slugged

  attr_accessible :remember_me, :nickname
  attr_accessor   :nickname

  # relationships ------------------------------------------------------------
  has_many :authorizations, dependent: :destroy
  has_many :lessons, dependent: :destroy

  # validations --------------------------------------------------------------
  validates_presence_of   :nickname

  # NOTE: this is not necessary, because FriendlyId will ensure uniqueness
  #   validates_uniqueness_of :slug

  # Creates a new user with the given nickname.
  # @param [String] nickname
  # @return [User]  user
  def self.register!(nickname)
    user = new nickname: nickname
    user.save!
    user
  end

  # @return [String] user's full name, as obtained from OAuth provider
  def name
    authorizations.first.try(:name) || 'Account'
  end

end
