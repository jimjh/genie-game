class LessonsController < ApplicationController

  protect_from_forgery except: [:push, :ready, :gone]
  before_filter :authenticate_user!, except: [:push, :ready, :gone]
  before_filter :authenticate_github!, only: [:push]
  skip_filter   :protect_closed_beta,  only: [:push, :ready, :gone]
  respond_to    :json

  INDEX_FILE    = 'index.inc'
  SETTINGS_PATH = Rails.root.join('app', 'views', 'lessons', 'settings').to_s

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

    path = Pathname.new(params[:path] || '').expand_path(lesson.compiled_path)
    path = path.sub_ext('.' + params[:format]) unless params[:format].blank?
    not_found unless path.to_s.starts_with?(lesson.compiled_path) and path.exist?

    # html_safe iff it's at the root - everything else is dangerous static asset
    if path.parent.to_s == lesson.compiled_path
      @contents = File.read path
      @answers  = lesson.answers_for current_user
    else send_file path, disposition: 'attachment'
    end

  end

  # GET /:user/:lesson/settings/:path
  def settings
    @user, @lesson, @path = params[:user], params[:lesson], params[:path]
    @lesson = Lesson.select(%w[lessons.id lessons.slug])
                    .for_user(@user).find(@lesson)
    # security check to prevent directory traversal attacks
    not_found unless File.expand_path(@path, SETTINGS_PATH).starts_with?(SETTINGS_PATH)
  end

  # POST /lessons
  def create
    # if ID is given, assume that user wants to toggle
    return toggle if params[:id]
    lesson = current_user.lessons.create params[:lesson]
    respond_with lesson, only: [:slug, :url, :status]
  end

  # Activate/Deactivate
  # POST /lessons/:id/toggle
  def toggle
    lesson = current_user.lessons.find params[:id]
    status = case params[:toggle]
    when 'off' then lesson.deactivate
    when 'on'  then lesson.activate
    end
    status = status ? :accepted : :unprocessable_entity
    respond_with lesson, only: [:slug, :url, :status], status: status
  end

  # Webhook that is registered with GitHub.
  # POST /lessons/push
  def push
    auth    = Authorization.find_by_provider_and_nickname! 'github',
      params[:repository][:owner][:name]
    lesson  = Lesson.find_by_user_id_and_name! auth.user.id,
      params[:repository][:name]
    status = lesson.pushed
    status = status ? :accepted : :unprocessable_entity
    respond_with lesson, only: [:slug, :url, :status], status: status
  end

  # Webhook that is registered with Lamp.
  # POST /lessons/:id/ready
  def ready
    lesson = Lesson.find params[:id]
    status = case params[:status]
    when '200' then lesson.published params[:payload]
    else lesson.failed
    end
    status = status ? :ok : :unprocessable_entity
    respond_with lesson, only: [:slug, :url, :status], status: status
  end

  # Webhook that is registered with Lamp.
  # POST /lessons/:id/gone
  def gone
    head :ok
  end

  # POST /:user/:lesson/verify
  def verify
    lesson  = Lesson.select('lessons.id')
                    .for_user(params[:user])
                    .find(params[:lesson])
    problem = lesson.problem_at params[:problem]
    answer = Answer.upsert current_user.id, problem.id, content: params[:answer]
    status = answer.save ? :ok : :unprocessable_entity
    respond_with answer, only: [:results], status: status, location: nil
  end

  private

  def authenticate_github!
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.config.github[:username] &&
        password == Rails.application.config.github[:password]
    end
  end

end
