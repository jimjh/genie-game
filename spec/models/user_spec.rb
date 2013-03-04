# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe User do

  it { should respond_to(:nickname) }
  it { should respond_to(:slug) }

  it { should have_many(:authorizations).dependent(:destroy) }
  it { should have_many(:lessons).dependent(:destroy) }

  it { should validate_presence_of(:nickname) }
  it { should have_a_valid_factory }

  its(:name) { should eq 'Account' }

  it 'uses the parameterized nickname in to_param' do
    u = FactoryGirl.create :user, nickname: 'a b c x/z'
    u.to_param.should eq 'a-b-c-x-z'
    u.destroy
  end

  describe '#register!' do

    before :each do
      @user = User.register! 'a nickname'
    end

    after :each do
      @user.destroy
    end

    it 'creates a single user' do
      @user.nickname.should eq 'a nickname'
      @user.slug.should eq 'a-nickname'
      User.find(@user.slug).id.should eq @user.id
    end

  end

  context 'given a single user' do

    before :each do
      @user = FactoryGirl.create :user
    end

    after :each do
      @user.destroy
    end

    describe '::find' do
      it 'finds the user by slug' do
        user = User.find @user.slug, select: 'id'
        user.id.should eq @user.id
      end
    end

    describe '#name' do
      it 'returns the user\'s full name' do
        auth = @user.authorizations.first
        @user.name.should eq auth.name
      end
    end

  end

end
