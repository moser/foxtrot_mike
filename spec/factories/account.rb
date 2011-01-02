Factory.define :account_role do |f|
  f.role :reader
end

Factory.define :account do |a|
  a.sequence(:login) { |n| "foo#{n}" }
  a.password '123123'
  a.password_confirmation '123123'
  a.association :person, :factory => :person
  a.account_roles { [AccountRole.generate!] }
end

Factory.define :account_session do |f|
end
