class Authorization < ActiveRecord::Base
  belongs_to :user
  attr_accessible :link, :name, :provider, :secret, :token, :uid
end
