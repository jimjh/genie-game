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
  it { should validate_uniqueness_of(:requestee_id).scoped_to(:requester_id) }

  context 'creating an access request' do

    subject { request }

    context 'that is pending' do
      let(:request) { FactoryGirl.create :access_request }
      its(:status)  { should eq 'pending' }
      it 'grants' do
        request.grant.should be true
     end
    end

  end

end

describe AccessRequest, '.granted' do

  it 'includes granted requests' do
    request = FactoryGirl.create :access_request, :granted
    AccessRequest.granted.should include(request)
  end

  it 'excludes non-granted requests' do
    request = FactoryGirl.create :access_request
    AccessRequest.granted.should_not include(request)
  end

end
