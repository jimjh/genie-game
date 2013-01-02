# ~*~ encoding: utf-8 ~*~
FactoryGirl.define do

  factory :user do
    name      { Faker::Name.name }
    nickname  { Faker::Name.first_name }
  end

end
