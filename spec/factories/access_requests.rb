FactoryGirl.define do

  factory :access_request do
    requester
    requestee
    trait :granted do
      granted_on { 1.day.ago }
    end
  end

end
