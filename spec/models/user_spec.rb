# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe User do

  it { should respond_to(:nickname) }
  it { should respond_to(:slug) }

  it { should have_many(:authorizations).dependent(:destroy) }
  it { should have_many(:lessons).dependent(:destroy) }

  it { should validate_presence_of(:nickname) }
  its(:name) { should eq 'Account' }

  it 'uses the parameterized nickname in to_param' do
    u = FactoryGirl.create :user, nickname: 'a b c x/z'
    u.to_param.should eq 'a-b-c-x-z'
    u.destroy
  end

  describe '#register!' do

    it 'creates a single user' do
      u = User.register! 'a nickname'
      u.nickname.should eq 'a nickname'
      u.slug.should eq 'a-nickname'
      User.find(u.id).id.should eq u.id
      u.destroy
    end

  end

  context 'given a single user' do

    before :each do
      @user = FactoryGirl.create :user
    end

    after :each do
      @user.destroy
    end

    describe '#name' do
      it 'returns the user\'s full name' do
        auth = @user.authorizations.first
        @user.name.should eq auth.name
      end
    end

  end

end
