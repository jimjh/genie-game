class User < ActiveRecord::Base

  devise :rememberable, :trackable, :token_authenticatable, :omniauthable
  attr_accessible :remember_me, :name
  has_many :authorizations, :dependent => :destroy

end
