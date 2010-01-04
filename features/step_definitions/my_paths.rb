Then /^(?:|I )should see an? (.+) page$/ do |page_name|
  current_path = URI.parse(current_url).select(:path, :query).compact.join('?')
  path = page_name.pluralize
  current_path.should =~ /\/#{path}\/(.+)/
end
