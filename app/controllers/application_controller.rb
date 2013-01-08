class ApplicationController < ActionController::Base

  protect_from_forgery

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def bad_request
    head :bad_request
  end

  alias :original_lesson_path :lesson_path
  def lesson_path(lesson, options={})
    original_lesson_path options.merge(user: lesson.user, lesson: lesson)
  end
  helper_method :lesson_path

  alias :original_lesson_url :lesson_url
  def lesson_url(lesson, options={})
    original_lesson_url options.merge(user: lesson.user, lesson: lesson)
  end
  helper_method :lesson_url

end
