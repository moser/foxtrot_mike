Given /^I am on the (.*) page$/ do |resource|
  BROWSER.goto("http://localhost:3000/#{resource}")
end

When /^I click the "(.*)" link$/ do |name|
  BROWSER.link(:text, name).click
end

When /^I wait until I see "(.*)"$/ do |text|
  wait_until_loaded { BROWSER.html.include?(text) }
  BROWSER.html.should include(text)
end
