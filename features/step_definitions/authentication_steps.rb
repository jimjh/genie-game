Given /^(?:|I )have a GitHub account$/ do
  @auth_hash = FactoryGirl.build :auth_hash
  OmniAuth.config.add_mock :github, @auth_hash
end

Given /^(?:|I )am signed in with GitHub$/ do
  visit user_omniauth_authorize_path :github
end

When /^(?:|I )sign in with GitHub$/ do
  visit user_omniauth_authorize_path :github
end

Then /^(?:|I )should see my name$/ do
  page.should have_content(@auth_hash['info']['name'])
end

Then /^(?:|I )should not see my name$/ do
  page.should_not have_content(@auth_hash['info']['name'])
end

When /^(?:|I )sign out$/ do
  visit root_path
  click_link 'Sign Out'
end
