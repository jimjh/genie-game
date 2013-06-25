class HomeController < ApplicationController

  def index
    if user_signed_in?
      @lessons = Lesson.published
    else render 'welcome'
    end
  end

  before_filter :authenticate_user!, only: [:tty]
  def tty
  end

end
