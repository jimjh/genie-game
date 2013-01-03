# ~*~ encoding: utf-8 ~*~
module ControllerHelpers
  def sign_in(user=double('user'))
    if user.nil?
      request.env['warden'].stubs(:authenticate!).throws(:warden, scope: :user)
      controller.stubs current_user: nil
    else
      request.env['warden'].stubs authenticate!: user
      controller.stubs current_user: user
    end
  end
end
