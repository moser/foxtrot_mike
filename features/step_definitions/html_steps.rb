When /^I should see "(.*)"$/ do |text|
  BROWSER.html.should include(text)
end
