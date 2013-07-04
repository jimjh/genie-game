class Usage < ActiveRecord::Base

  # relationships ------------------------------------------------------------
  with_options inverse_of: :usages do |assoc|
    assoc.belongs_to :user
    assoc.belongs_to :lesson
  end

  # attributes ---------------------------------------------------------------
  attr_readonly   :lesson_id, :user_id

  # validations --------------------------------------------------------------
  validates_presence_of :lesson, :user
  validates_numericality_of :use_count

  # Tracks usage by incrementing {#use_count}.
  def self.track(user, lesson)
    u = user.usages.first_or_create({ lesson: lesson }, { :without_protection => true })
    u.increment!(:use_count)
  end

end
