FactoryGirl.define do
  factory :wire_launcher_cost_category_membership do
    valid_from 1.year.ago.to_date
    valid_to 1.year.from_now.to_date
    wire_launcher
    wire_launcher_cost_category
  end

  factory :wire_launcher do
    sequence(:registration) {|n| "BY-#{n} #{DateTime.now}" }
    financial_account { FactoryGirl.create(:financial_account) }
  end

  factory :wire_launcher_cost_category do
    sequence(:name) {|n| "wire_launcher_cost_category #{n} #{DateTime.now}" }
  end

  factory :wire_launch do
    wire_launcher
    association :operator, factory: :person
    association :abstract_flight, factory: :flight
  end
end
