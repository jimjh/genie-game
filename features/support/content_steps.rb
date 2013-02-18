Then /^(?:|I )should see "([^"]*)"$/ do |text|
  page.should have_content(text)
end

Then /^(?:|I )should see '([^']*)'$/ do |text|
  page.should have_content(text)
end
