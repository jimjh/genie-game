# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe User do

  it { should respond_to(:remember_me) }
  it { should respond_to(:nickname) }
  it { should respond_to(:slug) }

  it { should have_many(:authorizations).dependent(:destroy) }
  it { should have_many(:lessons).dependent(:destroy) }

  it { should validate_presence_of(:nickname) }

  it 'should use the parameterized nickname in to_param' do
    u = FactoryGirl.create :user, nickname: 'a b c x/z'
    u.to_param.should eq 'a-b-c-x-z'
    u.destroy
  end

  describe 'register!' do

    it 'should create a single user' do
      u = User.register! 'a nickname'
      u.nickname.should eq 'a nickname'
      u.slug.should eq 'a-nickname'
      User.find(u.id).id.should eq u.id
    end

  end

end
