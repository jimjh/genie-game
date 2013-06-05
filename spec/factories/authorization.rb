# ~*~ encoding: utf-8 ~*~
FactoryGirl.define do

  factory :authorization do
    provider 'github'
    name     { Faker::Name.name }
    nickname { Faker::Internet.user_name }
    uid      { Random.rand(1000).to_s }
    token    { SecureRandom.uuid }
    user
  end

end
