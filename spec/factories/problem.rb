# ~*~ encoding: utf-8 ~*~
FactoryGirl.define do

  factory :problem do
    lesson
    digest { OpenSSL::Digest::SHA256.digest Faker::Lorem.sentence }
    sequence(:position)
  end

  factory :problem_digest, class: Hash do
    digest    { OpenSSL::Digest::SHA256.digest Faker::Lorem.sentence }
    to_create {}
    initialize_with { attributes }
  end

end
