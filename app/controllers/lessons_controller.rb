class LessonsController < ApplicationController

  # TODO: hacky hacky hacky

  def show
    # TODO: sanitize paths
    contents = File.read Pathname.new('/tmp/genie/compiled') + params[:user] + params[:project] + 'index.inc'
    @contents = contents.html_safe
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
