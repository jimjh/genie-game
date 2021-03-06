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
  with_options dependent: :destroy, inverse_of: :user do |assoc|
    assoc.has_many :authorizations
    assoc.has_many :lessons
    assoc.has_many :answers
    assoc.has_many :usages
  end
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

  def to_s
    auth = authorizations.first
    auth.try(:name) || auth.try(:nickname) || 'Account'
  end

  def email
    authorizations.first.try(:email)
  end

  def avatar(size=120)
    return nil unless email
    hash = OpenSSL::Digest.hexdigest('md5', email.strip.downcase)
    "https://secure.gravatar.com/avatar/#{hash}?d=identicon&s=#{size}"
  end

  def github_oauth!
    authorizations.find_by_provider! 'github'
  end

  def has_granted_requests?
    sent_access_requests.granted.any?
  end

end
