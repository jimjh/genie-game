# ~*~ encoding: utf-8 ~*~
FactoryGirl.define do

  factory :lesson do

    name      { Faker::Company.name }
    url       'git@github.com:jimjh/xyz.git'
    user

    trait :published do
      status 'published'
    end

    trait :deactivated do
      status 'deactivated'
    end

    trait :publishing do
      status 'publishing'
    end

  end

end
