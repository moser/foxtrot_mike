FactoryGirl.define do
  factory :account do
    sequence(:login) { |n| "foo#{n}#{Time.now.to_i}" }
    admin true
    crypted_password 'asf'
    password_salt 'asf'
    perishable_token 'asf'
    persistence_token 'asf'
    single_access_token 'asf'
    person
  end

  factory :account_session do
  end
end
