FactoryGirl.define do
  factory :person do
    lastname 'foo'
    firstname 'bar'
    group
    financial_account { FactoryGirl.create(:financial_account) }
  end

  factory :financial_account_ownership do
    valid_from 1.year.ago
    financial_account
  end

  factory :person_cost_category do
    sequence(:name) {|n| "person_cost_category #{n} #{DateTime.now}" }
  end

  factory :person_cost_category_membership do
    valid_from 1.year.ago.to_date
    valid_to 1.year.from_now.to_date
    person
    person_cost_category
  end

  factory :license do
    name "LALA"
    valid_from 1.year.ago
    person
  end
end
