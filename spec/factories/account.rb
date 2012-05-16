FactoryGirl.define do
  factory :account do
    sequence(:login) { |n| "foo#{n}#{Time.now.to_i}" }
    password '123123'
    password_confirmation '123123'
    admin true
    person
  end

  factory :account_session do
  end
end
