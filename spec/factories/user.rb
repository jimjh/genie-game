# ~*~ encoding: utf-8 ~*~
FactoryGirl.define do

  factory :user do
    name      { Faker::Name.name }
    nickname  { Faker::Name.first_name }
    ignore do
      authorizations_count 1
    end
    after :create do |user, ev|
      FactoryGirl.create_list :authorization, ev.authorizations_count, user: user
    end
  end

end
