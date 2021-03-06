# ~*~ encoding: utf-8 ~*~
FactoryGirl.define do

  factory :lesson do

    name      { Faker::Company.name }
    url       'git@github.com:jimjh/xyz.git'
    owner     { Faker::Internet.user_name }
    user

    trait :published do
      status          'published'
      compiled_path   Rails.root.join('tmp').to_s
    end

    trait :deactivated do
      status 'deactivated'
    end

    trait :publishing do
      status 'publishing'
    end

  end

end
