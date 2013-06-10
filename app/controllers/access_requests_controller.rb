class AccessRequestsController < ApplicationController

  before_filter :authenticate_user!
  respond_to :json, :html

  def create
    csv = params[:logins] || ''
    nicknames, errors = csv.split(/,\s*/), {}
    # create individually but keep track of errors
    status = nicknames.reduce(true) do |memo, nickname|
      ok, errs = make_request nickname
      errors[nickname] = errs unless ok
      memo and ok
    end
    status = status ? :ok : :unprocessable_entity
    render json: errors, status: status
  end

  def grant
    @req = current_user.received_access_requests.find params[:id]
    status = @req.grant ? :ok : :unprocessable_entity
    respond_with @req, status: status
  end

  def deny
    @req = current_user.received_access_requests.find params[:id]
    status = @req.deny ? :ok : :unprocessable_entity
    respond_with @req, status: status
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
