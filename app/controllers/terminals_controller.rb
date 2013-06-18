class TerminalsController < ApplicationController
  include TangleConcern

  before_filter :authenticate_user!

  def create
    tangle_client.transport.open
    id = tangle_client.ssh current_user.id.to_s, default_vm_class
    render json: { id: id }
  ensure
    tangle_client.transport.close
  end

  private

  def default_vm_class
    ''
  end

end
