module Features
  module SessionHelpers

    def sign_in
      OmniAuth.config.add_mock :github, FactoryGirl.create(:auth_hash)
      visit root_path
      click_link 'Sign In'
    end

    def sign_out
      click_link 'Sign Out'
    end

    RSpec::Matchers.define :be_signed_in do

      match do |actual|
        actual.has_content?(I18n.t 'nav.sign_out')
      end

      failure_message_for_should do |actual|
        'expected page to have signed in'
      end

      failure_message_for_should_not do |actual|
        'expected page to not have signed in'
      end

      description do
        'be signed in'
      end

      def with(credentials)
        # TODO
      end

    end

    RSpec::Matchers.define :be_signed_out do

      match do |actual|
        actual.has_content? I18n.t 'nav.sign_in'
      end

      failure_message_for_should do |actual|
        'expected page to have signed out'
      end

      failure_message_for_should_not do |actual|
        'expected page to not have signed out'
      end

      description do
        'be signed out'
      end

    end

  end
end
