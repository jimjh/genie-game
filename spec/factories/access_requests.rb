FactoryGirl.define do

  factory :access_request do
    requester
    requestee
    trait :granted do
      status 'granted'
    end
    trait :denied do
      status 'denied'
    end
  end

end
