FactoryGirl.define do
  factory :airfield do
    sequence(:name) {|n| "Airfield #{n} #{DateTime.now}" }
    sequence(:registration) {|n| "#{n} #{DateTime.now}" }
    lat 49.0
    long 12.0
  end
end
