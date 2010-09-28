# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :financial_account do |f|
  f.sequence(:name) { |n| "fa #{n}" }
end
