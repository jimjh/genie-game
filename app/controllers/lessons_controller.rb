require 'aladdin/support/weak_comparator'

class LessonsController < ApplicationController
  include Aladdin::Support::WeakComparator

  before_filter :authenticate_user!

  # TODO: configure
  COMPILED_PATH = Pathname.new '/tmp/genie/compiled'
  SOLUTION_PATH = Pathname.new '/tmp/genie/solution'
  SOLUTION_EXT  = '.sol'

  def index
  end

  def show
    # TODO: sanitize and validate params
    params[:path] ||= ''
    path = COMPILED_PATH + params[:user] + params[:project] + params[:path]
    if params[:format]
      file = path.to_s + '.' + params[:format]
      send_file file, disposition: 'inline'
    else
      path += 'index.inc' if path.directory?
      @contents = File.read(path).html_safe
    end
  end

  def new
    @lesson = Lesson.new
  end

  def create
    # TODO: use models for validation
    # TODO: test that I cannot be made to execute arbitrary commands
    @lesson = Lesson.new params[:lesson]
    if @lesson.save
      # TODO: validate outcome
      system 'lamp', 'create', params[:url], params[:name]
      flash[:notice] = 'XXX' # TODO: strings
      redirect_to @lesson
    else
      render action: 'new'
    end
  end

  def verify
    # TODO: sanitize and validate params
    solution  = params[:problem] + SOLUTION_EXT
    path      = SOLUTION_PATH + params[:user] + params[:project] + solution
    result    = File.open(path, 'rb') do |f|
      same? params[:answer], Marshal.restore(f)
    end
    render json: result
  end

end
