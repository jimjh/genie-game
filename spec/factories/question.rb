FactoryGirl.define do

  factory :question do
    lesson
    digest { OpenSSL::Digest::SHA256.digest Faker::Lorem.sentence }
    sequence(:position)
  end

end
