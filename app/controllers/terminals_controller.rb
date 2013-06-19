class TerminalsController < ApplicationController
  include TangleConcern

  before_filter :authenticate_user!

  def create
    id = tangle_client.invoke do |c|
      c.ssh current_user.id.to_s, default_vm_class
    end
    render json: { terminal_id: id }
  end

  private

  def default_vm_class
    ''
  end

end
