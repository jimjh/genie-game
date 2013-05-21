# ~*~ encoding: utf-8 ~*~
FactoryGirl.define do

  factory :compiled_lesson, class: OpenStruct do

    ignore do
      association :lesson_record, :published, factory: :lesson
    end

    user        { lesson_record.user.slug }
    lesson      { lesson_record.slug }
    root        { Pathname.new Dir.mktmpdir }
    lesson_path { root + user + lesson }
    index_file  { SecureRandom.uuid }

    to_create   do |i|
      i.lesson_record.compiled_path = i.lesson_path.to_s
      i.lesson_record.save!
      i.lesson_path.mkpath
      IO.write i.lesson_path + LessonsController::INDEX_FILE, i.index_file
    end

  end

end
