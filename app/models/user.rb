# == User
# User model empowered by devise. The +rememerable+ and +trackable+ devise
# modules automatically handle the following fields:
# - +remember_created_at+
# - +sign_in_count+
# - +{last,current}_sign_in_{at,ip}+
#
# The +omniauthable+ module handles integration with OmniAuth.
# - +nickname+ is a virtual field that is set when the user is created. It's
#   used to generate the +slugged+ field and can be any string value. However,
#   it is usually just the user's username from the first authorization.
# - +slug+ is generated by +friendly_id+ from +nickname+.
#
# Users do not need to have an authorization when they are created; however,
# every authorization must have a valid user.
class User < ActiveRecord::Base
  extend FriendlyId

  devise :rememberable, :trackable, :omniauthable
  friendly_id :nickname, use: :slugged

  # attributes ---------------------------------------------------------------
  attr_accessible :remember_me, :nickname
  attr_accessor   :nickname

  # relationships ------------------------------------------------------------
  has_many :authorizations, dependent: :destroy, inverse_of: :user
  has_many :lessons, dependent: :destroy, inverse_of: :user
  has_many :answers, dependent: :destroy, inverse_of: :user
  has_many :sent_access_requests,
    class_name: AccessRequest,
    foreign_key: :requester_id,
    dependent:   :destroy,
    inverse_of:  :requester,
    order:       'created_at desc'
  has_many :received_access_requests,
    class_name: AccessRequest,
    foreign_key: :requestee_id,
    dependent:   :destroy,
    inverse_of:  :requestee,
    order:       'created_at desc'

  # validations --------------------------------------------------------------
  validates_presence_of   :nickname

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

  def to_s
    auth = authorizations.first
    auth.try(:name) || auth.try(:nickname) || 'Account'
  end

end
