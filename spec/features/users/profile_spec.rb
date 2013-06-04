require 'spec_helper'

feature 'User visits profile' do

  background { sign_in }

  scenario 'sees some profile information' do
    visit settings_path
    page.should have_content 'member for less than a minute'
  end

end
