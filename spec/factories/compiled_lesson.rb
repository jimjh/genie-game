# ~*~ encoding: utf-8 ~*~
FactoryGirl.define do

  factory :compiled_lesson, class: OpenStruct do
    user        { SecureRandom.uuid }
    lesson      { Faker::Company.name }
    user_path   { LessonsController::COMPILED_PATH + user }
    lesson_path { user_path + lesson.parameterize }
    to_create   { |i| i.lesson_path.mkpath }
  end

end
