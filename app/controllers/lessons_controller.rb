class LessonsController < ApplicationController

  def show
    # TODO: sanitize params
    # TODO: allow configuration
    path = Pathname.new('/tmp/genie/compiled') + params[:path]
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

end
