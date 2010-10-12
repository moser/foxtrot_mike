# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :accounting_entry do |f|
  f.from_id 1
  f.to_id 1
  f.value 1
  f.item_id "MyString"
  f.item_type "MyString"
end
