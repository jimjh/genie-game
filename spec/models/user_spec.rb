# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe User do

  it { should respond_to(:nickname) }
  it { should respond_to(:slug) }

  it { should allow_mass_assignment_of :remember_me }
  it { should allow_mass_assignment_of :nickname }

  %w[created_at updated_at slug].each do |f|
    it { should_not allow_mass_assignment_of f.to_sym }
  end

  it { should have_many(:authorizations).dependent(:destroy) }
  it { should have_many(:lessons).dependent(:destroy) }
  it { should have_many(:answers).dependent(:destroy) }
  it {
    should have_many(:sent_access_requests)
      .class_name(AccessRequest)
      .dependent(:destroy)
      .with_foreign_key(:requester_id)
  }
  it {
    should have_many(:received_access_requests)
      .class_name(AccessRequest)
      .dependent(:destroy)
      .with_foreign_key(:requestee_id)
  }

  it { should validate_presence_of(:nickname) }
  it { should have_a_valid_factory }

  its(:name) { should eq 'Account' }

  it 'uses the parameterized nickname in to_param' do
    u = FactoryGirl.create :user, nickname: 'a b c x/z'
    u.to_param.should eq 'a-b-c-x-z'
    u.destroy
  end

  describe '#register!' do

    let(:user) { User.register! 'a nickname' }
    subject { user }

    its(:nickname) { should eq 'a nickname' }
    its(:slug) { should eq 'a-nickname' }
    it 'creates a single user' do
      User.find(user.slug).id.should eq user.id
    end

  end

  context 'given a single user' do

    let(:user) { FactoryGirl.create :user }

    describe '::find' do
      it 'finds the user by slug' do
        found = User.find user.slug, select: 'id'
        found.id.should eq user.id
      end
    end

    describe '#name' do
      it "returns the user's full name" do
        auth = user.authorizations.first
        user.name.should eq auth.name
      end
    end

  end

end
