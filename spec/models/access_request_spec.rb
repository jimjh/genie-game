require 'spec_helper'

describe AccessRequest do

  it { should belong_to(:requester).class_name(User) }
  it { should belong_to(:requestee).class_name(User) }

  it { should have_readonly_attribute :requester_id }
  it { should have_readonly_attribute :requestee_id }

  it { should have_a_valid_factory }

  %w[requester requester_id requestee requestee_id
     granted_on created_at updated_at].each do |f|
    it { should_not allow_mass_assignment_of f.to_sym }
  end

  it { should validate_presence_of :requester }
  it { should validate_presence_of :requestee }

  context 'creating an access request' do

    subject { request }

    context 'without a granted_on date' do
      let(:request) { FactoryGirl.create :access_request }
      it { should_not be_granted }
      it 'grants' do
        request.grant.should be true
        request.reload.granted_on.should <= Time.now
      end
    end

    context 'with a granted_on date in the past' do
      let(:request) { FactoryGirl.create :access_request, :granted }
      it { should be_granted }
      it 'does not grant' do
        request.grant.should be false
      end
    end

    context 'with a granted_on date in the future' do
      let(:request) { FactoryGirl.create :access_request, granted_on: 1.month.from_now }
      it { should_not be_granted }
      it 'does not grant' do
        request.grant.should be false
      end
    end

  end

end
