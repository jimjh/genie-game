class User < ActiveRecord::Base

  devise :rememberable, :trackable, :token_authenticatable, :omniauthable
  attr_accessible :remember_me, :name, :nickname
  has_many :authorizations, :dependent => :destroy

  def to_param
    nickname.parameterize
  end

end
