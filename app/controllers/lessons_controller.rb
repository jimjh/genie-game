require 'aladdin/support/weak_comparator'

class LessonsController < ApplicationController
  include Aladdin::Support::WeakComparator

  protect_from_forgery except: [:push, :ready, :gone]
  before_filter :authenticate_user!, except: [:show, :verify, :push, :ready, :gone]
  before_filter :authenticate_github!, only: [:push]
  respond_to    :json

  SOLUTION_EXT  = '.sol'
  INDEX_FILE    = 'index.inc'

  # Renders a single lesson page and its static assets.
  # @note It's important to use +attachment+ for send_file, because the user
  #   could have supplied a javascript-laden HTML file as a static file.
  #   Without the attachment disposition, the browser could choose to render
  #   it and execute malicious code.
  # @todo TODO Cache static assets, so that they don't have to pass through
  #   here.
  def show

    user   = User.find params[:user], select: 'id'
    lesson = user.lessons.find params[:lesson], select: 'compiled_path'

    lesson_dir = Pathname.new lesson.compiled_path
    path       = lesson_dir + (params[:path] || '')

    path  = path.sub_ext('.' + params[:format]) unless params[:format].blank?
    path += INDEX_FILE if path.directory?
    not_found unless path.exist?

    # html_safe iff it's at the root - everything else is dangerous static
    # asset
    if path.parent == lesson_dir then @contents = File.read(path)
    else send_file path, disposition: 'attachment' end

  end

  def create
    lesson      = Lesson.new params[:lesson]
    lesson.user = current_user
    lesson.save
    respond_with lesson
  end

  # Webhook that is registered with GitHub.
  # POST /lessons/push
  def push
    auth    = Authorization.find_by_provider_and_nickname! 'github',
      params[:repository][:owner][:name]
    lesson  = Lesson.find_by_user_id_and_name! auth.user.id,
      params[:repository][:name]
    lesson.pushed
    respond_with lesson
  end

  # Webhook that is registered with Lamp.
  # POST /lessons/:id/ready
  def ready
    case params['status']
    when '200'
      payload = params[:payload]
      lesson  = Lesson.find_by_id! params[:id]
      lesson.published payload
    else
      lesson = Lesson.find_by_id! params[:id]
      lesson.failed
    end
    respond_with lesson
  end

  # Webhook that is registered with Lamp.
  # POST /lessons/:id/gone
  def gone
    head :ok
  end

  def verify
    user   = User.find params[:user], select: 'id'
    lesson = user.lessons.find params[:lesson], select: 'solution_path'
    solution  = params[:problem] + SOLUTION_EXT
    path      = Pathname.new(lesson.solution_path) + solution
    not_found unless path.file?
    result    = File.open(path, 'rb') { |f| same? params[:answer], Marshal.restore(f) }
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
