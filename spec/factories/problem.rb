FactoryGirl.define do

  factory :problem do
    lesson
    digest { OpenSSL::Digest::SHA256.digest Faker::Lorem.sentence }
    sequence(:position)
  end

end
