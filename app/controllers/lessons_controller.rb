require 'aladdin/support/weak_comparator'

class LessonsController < ApplicationController
  include Aladdin::Support::WeakComparator

  protect_from_forgery except: [:push, :ready, :gone]
  before_filter :authenticate_user!, except: [:push, :ready, :gone]
  before_filter :authenticate_github!, only: [:push]
  skip_filter   :protect_closed_beta,  only: [:push, :ready, :gone]
  respond_to    :json

  INDEX_FILE    = 'index.inc'

  # Renders a single lesson page and its static assets.
  # @note It's important to use +attachment+ for send_file, because the user
  #   could have supplied a javascript-laden HTML file as a static file.
  #   Without the attachment disposition, the browser could choose to render
  #   it and execute malicious code.
  # @todo TODO Cache static assets, so that they don't have to pass through
  #   here.
  def show

    lesson = Lesson.select(%w[lessons.id compiled_path status])
                   .for_user(params[:user])
                   .find(params[:lesson])
    not_found unless lesson.published?

    lesson_dir = Pathname.new lesson.compiled_path
    path       = lesson_dir + (params[:path] || '')

    path  = path.sub_ext('.' + params[:format]) unless params[:format].blank?
    path += INDEX_FILE if path.directory?
    not_found unless path.exist?

    # html_safe iff it's at the root - everything else is dangerous static
    # asset
    if path.parent == lesson_dir
      @contents = File.read path
      @answers  = lesson.answers_for current_user
    else send_file path, disposition: 'attachment' end

  end

  def create
    # if ID is given, assume that user wants to toggle
    return toggle if params[:id]
    lesson = current_user.lessons.create params[:lesson]
    respond_with lesson, only: [:slug, :url, :status]
  end

  # Activate/Deactivate
  # TODO error handling - should I use save instead of save!?
  # POST /lessons/:id/toggle
  def toggle
    lesson = current_user.lessons.find params[:id]
    case params[:toggle]
    when 'off' then lesson.deactivate
    when 'on'  then lesson.pushed
    end
    respond_with lesson, only: [:slug, :url, :status], status: :accepted
  end

  # Webhook that is registered with GitHub.
  # POST /lessons/push
  def push
    auth    = Authorization.find_by_provider_and_nickname! 'github',
      params[:repository][:owner][:name]
    lesson  = Lesson.find_by_user_id_and_name! auth.user.id,
      params[:repository][:name]
    lesson.pushed if lesson.published?
    respond_with lesson, only: [:slug, :url, :status]
  end

  # Webhook that is registered with Lamp.
  # TODO error handling - should I use save instead of save!?
  # POST /lessons/:id/ready
  def ready
    case params[:status]
    when '200'
      payload = params[:payload]
      lesson  = Lesson.find_by_id! params[:id]
      lesson.published payload
    else
      lesson = Lesson.find_by_id! params[:id]
      lesson.failed
    end
    respond_with lesson, only: [:slug, :url, :status], status: :ok
  end

  # Webhook that is registered with Lamp.
  # POST /lessons/:id/gone
  def gone
    head :ok
  end

  def verify
    lesson  = Lesson.select('lessons.id').for_user(params[:user]).find(params[:lesson])
    problem = lesson.problem_at params[:problem]
    answer = Answer.upsert current_user.id, problem.id, content: params[:answer]
    answer.save!
    result = same? params[:answer], Marshal.load(problem.solution)
    render json: result
  end

  private

  def authenticate_github!
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.config.github[:username] &&
        password == Rails.application.config.github[:password]
    end
  end

end
