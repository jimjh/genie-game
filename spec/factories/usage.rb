FactoryGirl.define do
  factory :usage do
    use_count 1
    user
    lesson
  end
end
