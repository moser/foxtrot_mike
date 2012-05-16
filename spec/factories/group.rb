FactoryGirl.define do
  factory :group do
    sequence(:name) { |n| "Group #{n} #{DateTime.now}" }
  end
end
