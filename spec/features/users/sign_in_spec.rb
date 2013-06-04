require 'spec_helper'

feature 'User signs in' do

  background { sign_in }

  scenario 'sees a sign out link' do
    visit root_path
    page.should be_signed_in
  end

end

feature 'User did not sign in' do

  scenario 'sees a sign in link' do
    visit root_path
    page.should be_signed_out
  end

end

feature 'User signs out' do

  background { sign_in; sign_out }

  scenario 'sees a sign in link' do
    visit root_path
    page.should be_signed_out
  end

end
