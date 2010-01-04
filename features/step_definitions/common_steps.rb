Given /^an? (.+) record:$/ do |model, fields|
  m = Factory.build(model)
  fields.rows_hash.each do |name, value|
    m.send("#{name}=", value)
  end
  m.save
end

Given /^an? (.+) record$/ do |model|
  m = Factory.build(model)
  m.save
end

Then /^(?:|I )should see an? (.+) page$/ do |page_name|
  current_path = URI.parse(current_url).select(:path, :query).compact.join('?')
  path = page_name.pluralize
  current_path.should =~ /\/#{path}\/(.+)/
end

Then /^there should be no (.+)$/ do |model|
  model.singularize.camelize.constantize.count.should == 0
end
