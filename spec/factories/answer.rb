FactoryGirl.define do

  factory :answer do
    problem
    user
    content { Faker::Lorem.sentence }
  end

end
