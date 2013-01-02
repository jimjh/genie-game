# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe User do

  it { should respond_to(:name) }
  it { should respond_to(:remember_me) }
  it { should respond_to(:nickname) }

  it { should have_many(:authorizations).dependent(:destroy) }
  it { should have_many(:lessons).dependent(:destroy) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:nickname) }

  it 'should use the parameterized nickname in to_param' do
    u = FactoryGirl.build :user, nickname: 'a b c x/z'
    u.to_param.should eq 'a-b-c-x-z'
  end

  describe 'register!' do

    it 'should create a single user' do
      u = User.register! 'my full name', 'a nickname'
      u.name.should eq 'my full name'
      u.nickname.should eq 'a nickname'
      User.find(u.id).id.should eq u.id
    end

  end

end
