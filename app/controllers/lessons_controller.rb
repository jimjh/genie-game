require 'aladdin/support/weak_comparator'

class LessonsController < ApplicationController
  include Aladdin::Support::WeakComparator

  # TODO: configure
  COMPILED_PATH = Pathname.new '/tmp/genie/compiled'
  SOLUTION_PATH = Pathname.new '/tmp/genie/solution'
  SOLUTION_EXT  = '.sol'

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
    # TODO: form needs to be rewritten to use a Lesson model.
  end

  def create
    # TODO: use models for validation
    %x{lamp create #{params[:url]} #{params[:name]}}
    render action: 'new'
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
