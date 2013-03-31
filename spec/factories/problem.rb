# ~*~ encoding: utf-8 ~*~
FactoryGirl.define do

  factory :problem do
    lesson
    solution { Base64.urlsafe_encode64 Marshal.dump Faker::Lorem.sentence }
    digest   { OpenSSL::Digest::SHA256.digest Faker::Lorem.sentence }
    sequence(:position)
  end

  factory :problem_digest, class: Hash do
    solution  { Base64.urlsafe_encode64 Marshal.dump Faker::Lorem.sentence }
    digest    { OpenSSL::Digest::SHA256.digest Faker::Lorem.sentence }
    to_create {}
    initialize_with { attributes }
  end

end
