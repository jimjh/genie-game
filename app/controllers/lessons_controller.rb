require 'aladdin/support/weak_comparator'

class LessonsController < ApplicationController
  include Aladdin::Support::WeakComparator

  class InvalidParameters < StandardError; end

  protect_from_forgery except: :push
  before_filter :authenticate_user!, except: [:show, :verify, :push]
  rescue_from InvalidParameters do |e| bad_request end

  # TODO: configure
  COMPILED_PATH = Pathname.new '/tmp/genie/compiled'
  SOLUTION_PATH = Pathname.new '/tmp/genie/solution'
  SOLUTION_EXT  = '.sol'
  INDEX_FILE    = 'index.inc'

  # Renders a single lesson page and its static assets.
  # @note It's important to use +attachment+ for send_file, because the user
  #   could have supplied a javascript-laden HTML file as a static file.
  #   Without the attachment disposition, the browser could choose to render
  #   it and execute malicious code.
  def show

    # TODO cache static assets, so that they don't have to pass through here
    #   be careful of HTML and JS assets.
    validate_params! :user, :lesson
    lesson_dir = sanitize_path! COMPILED_PATH, params[:user], params[:lesson]
    path       = sanitize_path! lesson_dir, params[:path]

    path  = path.sub_ext('.' + params[:format]) unless params[:format].blank?
    path += INDEX_FILE if path.directory?
    not_found unless path.exist?

    # html_safe iff it's at the root - every else is dangerous static asset
    if path.parent == lesson_dir then @contents = File.read(path).html_safe
    else send_file path, disposition: 'attachment' end

  end

  def create
    @lesson      = Lesson.new params[:lesson]
    @lesson.user = current_user
    @lesson.save!                                           # TODO: errors
    system 'lamp', 'create', @lesson.url, @lesson.path.to_s # TODO: errors
    render nothing: true, status: 200
  end

  # Webhook that is registered with GitHub.
  # POST /lessons/push
  def push
    payload = JSON.parse params[:payload] rescue raise InvalidParameters.new('Missing payload.')
    auth    = Authorization.find_by_provider_and_nickname! 'github', payload['repository']['owner']['name']
    lesson  = Lesson.find_by_user_id_and_name! auth.user.id, payload['repository']['name']
    system 'lamp', 'create', lesson.url, lesson.path.to_s
    render nothing: true, status: 200
  rescue NoMethodError
    raise InvalidParameters.new 'Unexpected payload.'
  end

  def verify
    # TODO: use judge service
    validate_params! :user, :lesson, :problem

    solution  = params[:problem] + SOLUTION_EXT
    path      = sanitize_path!(SOLUTION_PATH, params[:user], params[:lesson], solution)
    not_found unless path.file?
    result    = File.open(path, 'rb') { |f| same? params[:answer], Marshal.restore(f) }

    render json: result
  end

  alias :original_lesson_url :lesson_url
  def lesson_url(lesson, options={})
    original_lesson_url options.merge(user: lesson.user, lesson: lesson)
  end
  helper_method :lesson_url

  private

  # Ensures that the arguments in +dangerous+ are not blank after
  #  parameterization.
  # @raise  [InvalidParameters] if the parameters are not valid.
  # @return [Void]
  def validate_params!(*dangerous)
    dangerous.each { |d| params[d] = params[d].try(:parameterize) }
    if dangerous.map { |d| params[d].blank? }.inject(:|)
      raise InvalidParameters.new 'Encountered suspicious parameters: %s' % params
    end
  end

  # Joins arguments into a single path and ensures that it's a descendant of
  # +base+.
  # @note   The check needs to be done stepwise to ensure that each parameter
  #   descends the directory.
  # @raise  [InvalidParameters] if the path is suspicious
  # @param  [Pathname] base
  # @return [Pathname]
  def sanitize_path!(base, *args)
    args.compact.reduce(base) do |memo, arg|
      candidate = memo + arg
      unless candidate.cleanpath.to_s.starts_with?(memo.to_s + File::SEPARATOR)
        raise InvalidParameters.new 'Encountered suspicious path: %s' % args
      end
      candidate
    end
  end

end
