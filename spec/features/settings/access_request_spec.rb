require 'spec_helper'

feature 'Creating new access request' do

  background do
    sign_in
    visit settings_authorizations_path
    @users = (1..5).map { FactoryGirl.create(:user) }
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

  background do
    sign_in
    @user = User.first
    @req  = FactoryGirl.create :access_request, requestee: @user
    visit settings_authorizations_path
  end

  scenario 'a pending request', :js do
    click_link "grant_#{@req.id}"
    page.should have_content @user.to_s
    @req.reload.status.should == 'granted'
  end

  scenario 'a denied request', :js do
    @req.deny
    visit settings_authorizations_path
    click_link "grant_#{@req.id}"
    page.should have_content @user.to_s
    @req.reload.status.should == 'granted'
  end

end

feature 'Denying' do

  background do
    sign_in
    @user = User.first
    @req  = FactoryGirl.create :access_request, requestee: @user
    visit settings_authorizations_path
  end

  scenario 'a pending request', :js do
    click_link "deny_#{@req.id}"
    page.should have_content @user.to_s
    @req.reload.status.should == 'denied'
  end

  scenario 'a granted request', :js do
    @req.grant
    visit settings_authorizations_path
    click_link "deny_#{@req.id}"
    page.should have_content @user.to_s
    @req.reload.status.should == 'denied'
  end

end
