# ~*~ encoding: utf-8 ~*~
FactoryGirl.define do

  factory :lesson do
    name      'xyz'
    url       'git@github.com:jimjh/xyz.git'
    user
  end

end
