When /^(?:|I )go to (.+)$/ do |name|
  visit path_to name
end

Then /^(?:|I )should see "([^"]+)"$/ do |text|
  page.should have_content(text)
end

Then /^(?:|I )should see '([^']+)'$/ do |text|
  page.should have_content(text)
end
