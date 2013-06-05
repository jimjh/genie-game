require 'spec_helper'

feature 'Creating new access request' do


  background do
    sign_in
    visit settings_authorizations_path
    @users = (1..5).map { FactoryGirl.create(:user) }
  end

  scenario 'with non-existent requestees'

  scenario 'with requestees who have pending requests'

  scenario 'with valid requestees', :js do
    logins = @users.map { |u| u.authorizations.first.nickname }
    fill_in 'logins',
      with: "#{logins[0]}, #{logins[1]},#{logins[2]},   #{logins[3]},,"
    click_button 'Send'
    logins.each { |l| page.should have_content l }
  end

end
