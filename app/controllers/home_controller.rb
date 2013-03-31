class HomeController < ApplicationController

  skip_filter :protect_closed_beta, only: [:closed_beta] # TODO: remove

  def index
    @lessons = Lesson.published
  end

  def closed_beta
    codes = YAML.load_file(Rails.root.join 'config', 'beta.yml')[:codes]
    redirect_to_launchrock unless codes.include? params[:invite]
    cookies[:beta] = BETA_SECRET
  end

end
