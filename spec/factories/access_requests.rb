FactoryGirl.define do

  factory :access_request do
    requester
    requestee
    trait :granted do
      status 'granted'
    end
  end

end
