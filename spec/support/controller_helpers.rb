# ~*~ encoding: utf-8 ~*~
module Test
  module ControllerHelpers

    def oauth_in
      request.env['warden'].stubs(:authenticate!).throws(:warden, scope: :user)
      controller.stubs current_user: nil
    end

    def random_file(path)
      rand = SecureRandom.uuid
      IO.write path, ( block_given? ? yield(rand) : rand )
      rand
    end

    def github_http_login
      user = Rails.application.config.github[:username]
      pw =   Rails.application.config.github[:password]
      request.env['HTTP_AUTHORIZATION'] = \
        ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
    end

  end
end
