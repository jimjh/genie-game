# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Users::OmniauthCallbacksController do

  before :each do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'GET /users/auth/:provider' do

    context 'with a valid provider' do
      it 'redirects to the GitHub site' do
        sign_in nil
        expect { get :passthru, provider: 'github' }.to raise_error(ActionController::RoutingError)
        response.should be_success
      end
    end

  end

  describe 'GET #github' do

    before(:each) { sign_in nil }

    shared_examples 'authentication' do

      before :each do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
        get :github
      end

      it 'authenticates the user and shows a success notice' do
        response.should be_redirect
        flash[:notice].should match(/success/i)
        User.count.should eq @count
      end

      it 'saves the given auth hash to the session' do
        session['devise.github_data'].should eq OmniAuth.config.mock_auth[:github]
      end

    end

    context 'with existing provider-uid pair' do

      before :each  do
        @user = FactoryGirl.create :user
        auth  = @user.authorizations.first
        OmniAuth.config.add_mock :github, FactoryGirl.build(:auth_hash, provider: auth.provider, uid: auth.uid)
        @count = User.count
      end

      after(:each) { @user.destroy }

      it_behaves_like 'authentication'

    end

    context 'with new provider-uid pair' do

      before :each do
        OmniAuth.config.add_mock :github, FactoryGirl.build(:auth_hash)
        @count = User.count + 1
      end

      it_behaves_like 'authentication'

    end

    context 'with invalid attributes' do

      it 'raises an ActiveRecord::RecordInvalid error' do
        info = FactoryGirl.build :auth_hash_info, name: ''
        OmniAuth.config.add_mock :github, FactoryGirl.build(:auth_hash, info: info)
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
        expect { get :github }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'raises an NoSuchMethod for nil error' do
        hash = FactoryGirl.build :auth_hash
        hash.delete :extra
        OmniAuth.config.add_mock :github, hash
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
        expect { get :github }.to raise_error(NoMethodError)
      end

    end

  end

end
