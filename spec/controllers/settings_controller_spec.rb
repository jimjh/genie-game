require 'spec_helper'

describe SettingsController do

  before :each do
    @user = FactoryGirl.create :user
    sign_in User.first
  end

  describe '#repositories' do

    it 'retrieves a list of repositories belonging to the user'

    context 'with github service error' do
      before :each do
        Github::Client.any_instance.stubs(:repos)
          .raises(Github::Error::ServiceError, {})
      end
      it 'shows a flash message' do
        get :repositories, sync: true
        flash[:error].should eq I18n.t('messages.settings.failures.github_service')
      end
    end

  end

end
