require 'aladdin/support/weak_comparator'

class LessonsController < ApplicationController
  include Aladdin::Support::WeakComparator

  before_filter :authenticate_user!, except: [:show, :verify]

  # TODO: configure
  COMPILED_PATH = Pathname.new '/tmp/genie/compiled'
  SOLUTION_PATH = Pathname.new '/tmp/genie/solution'
  SOLUTION_EXT  = '.sol'

  def show
    # TODO: sanitize and validate params
    params[:path] ||= ''
    path = COMPILED_PATH + params[:user] + params[:lesson] + params[:path]
    if params[:format]
      file = path.to_s + '.' + params[:format]
      not_found unless File.exist?(file)
      send_file file, disposition: 'inline'
    else
      path += 'index.inc' if path.directory?
      not_found unless path.exist?
      @contents = File.read(path).html_safe
    end
  end

  def create
    # TODO: test that I cannot be made to execute arbitrary commands
    @lesson = Lesson.new params[:lesson]
    @lesson.user = current_user
    @lesson.save!  # TODO: validate outcome and handle errors
    system 'lamp', 'create', @lesson.url, @lesson.path.to_s # TODO: errors
  end

  def verify
    # TODO: sanitize and validate params
    solution  = params[:problem] + SOLUTION_EXT
    path      = SOLUTION_PATH + params[:user] + params[:lesson] + solution
    result    = File.open(path, 'rb') do |f|
      same? params[:answer], Marshal.restore(f)
    end
    render json: result
  end

  alias :original_lesson_url :lesson_url
  def lesson_url(lesson, options={})
    original_lesson_url options.merge(user: lesson.user, lesson: lesson)
  end
  helper_method :lesson_url

end
