class AccessRequestsController < ApplicationController

  before_filter :authenticate_user!
  respond_to :json, :html

  def create
    csv = params[:logins] || ''
    nicknames, errors = csv.split(/,\s*/), {}
    status = nicknames.reduce(true) do |memo, nickname|
      ok, errs = make_request nickname
      errors[nickname] = errs unless ok
      memo and ok
    end
    status = status ? :ok : :unprocessable_entity
    render json: errors, status: status
  end

  private

  def make_request(nickname)
    req = AccessRequest.build_with_nickname current_user, nickname
    return req.save, req.errors
  rescue ActiveRecord::RecordNotFound
    return false, {
      requestee_id: I18n.t('activerecord.errors.models.access_request.attributes.requestee.not_found')
    }
  end

end
