require 'spec_helper'

feature 'Creating new access request' do

  background do
    sign_in
    visit settings_authorizations_path
    @users = (1..5).map { FactoryGirl.create(:user).reload }
  end

  scenario 'with non-existent requestees'

  scenario 'with requestees who have pending requests'
  scenario 'with duplicate requestees'

  scenario 'with valid requestees', :js do
    logins = @users.map(&:slug)
    fill_in 'logins',
      with: "#{logins[1]}, #{logins[2]},#{logins[3]},   #{logins[4]},,"
    click_button 'Send'
    @users.last(4).each { |u| page.should have_content u.to_s }
    page.should_not have_content @users.first.to_s
  end

end

feature 'Granting' do

  let(:user) { User.first }
  let(:req)  { FactoryGirl.create :access_request, requestee: user }

  background do
    sign_in
    req
    visit settings_authorizations_path
    click_link "grant_#{req.id}"
  end

  shared_examples 'grants the request' do
    scenario 'grants the request', :js do
      page.should have_content user.to_s
      req.reload.status.should == 'granted'
    end
  end

  context 'a pending request' do
    include_examples 'grants the request'
  end

  context 'a denied request' do
    let(:req)  { FactoryGirl.create :access_request, :denied, requestee: user }
    include_examples 'grants the request'
  end

end

feature 'Denying' do

  let(:user) { User.first }
  let(:req)  { FactoryGirl.create :access_request, requestee: user }

  background do
    sign_in
    req
    visit settings_authorizations_path
    click_link "deny_#{req.id}"
  end

  shared_examples 'denies the request' do
    scenario 'denies the request', :js do
      page.should have_content user.to_s
      req.reload.status.should == 'denied'
    end
  end

  context 'a pending request' do
    include_examples 'denies the request'
  end

  context 'a granted request' do
    let(:req) { FactoryGirl.create :access_request, :granted, requestee: user }
    include_examples 'denies the request'
  end

end

feature 'Exporting' do

  let(:user)     { FactoryGirl.create(:user).reload }
  let(:requests) { (1..10).to_a.map { FactoryGirl.create :access_request, :granted, requester: user } }
  let(:answers)  { requests.map(&:requestee).map { |user| FactoryGirl.create :answer, user: user } }

  background do
    sign_in_as user
    answers
    visit settings_authorizations_path
    click_link 'Export'
  end

  scenario 'exports the data as csv' do
    page.response_headers['Content-Disposition'].should include 'attachment'
    page.response_headers['Content-Disposition'].should include '.csv'
    data = CSV.parse(page.source)
    data.should be_kind_of Array
    data.length.should be 11
  end

end
