Given /^a person named (.+) (.+)$/ do |firstname, lastname|
  Factory.create(:person, :firstname => firstname, :lastname => lastname)
end

