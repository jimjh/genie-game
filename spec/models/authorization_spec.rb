# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Authorization do

  [:link, :name, :nickname, :provider, :secret, :token, :uid].each do |attr|
    it { should respond_to(attr) }
  end

  [:provider, :uid, :user_id, :token].each do |attr|
    it { should validate_presence_of(attr) }
  end

  it { should belong_to(:user) }

  describe '#user' do

    before :each do
      @user   = FactoryGirl.create :user
    end

    after :each do
      [@user].map(&:destroy)
    end

    it 'should ensure that user exists' do
      FactoryGirl.build(:authorization, user_id: @user.id + 1).should_not be_valid
      FactoryGirl.build(:authorization, user_id: @user.id).should be_valid
    end

  end

end
