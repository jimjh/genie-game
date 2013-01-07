# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Authorization do

  [:link, :name, :nickname, :provider, :secret, :token, :uid].each do |attr|
    it { should respond_to(attr) }
  end

  [:provider, :uid, :user_id, :token, :nickname].each do |attr|
    it { should validate_presence_of(attr) }
  end

  it { should belong_to(:user) }

  describe '#user' do

    context 'given an existing user' do
      before(:each) { @user   = FactoryGirl.create :user }
      after(:each)  { [@user].map(&:destroy) }
      it 'allows the authorization to be created' do
        FactoryGirl.build(:authorization, user_id: @user.id).should be_valid
      end
    end

    context 'given a non-existent user' do
      it 'denys the authorization' do
        ids = User.pluck :id
        begin id = Random.rand(1000) end while ids.include?(id)
        FactoryGirl.build(:authorization, user_id: id).should_not be_valid
      end
    end

  end

end
