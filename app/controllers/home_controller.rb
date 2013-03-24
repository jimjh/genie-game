class HomeController < ApplicationController

  def index
    @lessons = Lesson.published
  end

end
