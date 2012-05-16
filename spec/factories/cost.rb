FactoryGirl.define do
  factory :cost_rule_condition do
  end

  factory :financial_account do
    sequence(:name) { |n| "fa #{n}" }
  end

  factory :cost_hint do
    sequence(:name) { |n| "CostHint#{n}" }
  end

  factory :flight_cost_item do
  end

  factory :flight_cost_rule do
    valid_from 1.day.ago
    sequence(:name) { |n| "flight_cost_rule #{n} #{DateTime.now}" }
    flight_type "Flight"
    plane_cost_category
    person_cost_category
  end

  factory :wire_launch_cost_item do
  end

  factory :wire_launch_cost_rule do
    sequence(:name) { |n| "wire_launch_cost_rule #{n} #{DateTime.now}" }
    valid_from 1.month.ago.to_date
    wire_launcher_cost_category
    person_cost_category
  end

  factory(:accounting_session) do
    sequence(:name) { |n| "accounting_session #{n} #{DateTime.now}" }
    sequence(:end_date) { |n| (500 - n).days.ago }
    sequence(:voucher_number) { |n| n }
    accounting_date Date.today
  end
end
