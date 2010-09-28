# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :account_session do |f|
end

  Factory.define :account do |a|
    a.sequence(:login) { |n| "foo#{n}" }
    a.password '123123'
    a.password_confirmation '123123'
    a.association :person, :factory => :person
  end
