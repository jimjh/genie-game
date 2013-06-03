class HomeController < ApplicationController

  def index
    if user_signed_in?
      @lessons = Lesson.published
    else render 'welcome'
    end
  end

end
