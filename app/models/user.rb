class User < ActiveRecord::Base

  devise :rememberable, :trackable, :token_authenticatable, :omniauthable

  attr_accessible :remember_me, :name, :nickname

  has_many :authorizations, :dependent => :destroy
  has_many :lessons, :dependent => :destroy

  # TODO: validations

  # Creates a new user with the given name and nickname.
  # @param [String] name
  # @param [String] nickname
  # @return [User]  user
  def self.register!(name, nickname)
    user = new name: name, nickname: nickname
    user.save!
    user
  end

  # Use nickname for constructing URLs instead of user ID.
  def to_param
    nickname.parameterize
  end

end
