class AnswersController < ApplicationController

  before_filter :authenticate_user!
  respond_to :json

  # POST /answers
  def create
    lesson  = Lesson.find params[:lesson_id]
    problem = lesson.problem_at params[:position]
    answer  = Answer.upsert current_user.id, problem.id, content: params[:answer]
    answer.save
    respond_with answer, only: [:results]
  end

end
