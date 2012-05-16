FactoryGirl.define do
  factory :plane do
    sequence(:registration) {|n| "D-#{n} #{DateTime.now}" }
    make "Lala"
    group
    legal_plane_class
    financial_account { FactoryGirl.create(:financial_account) }
  end

  factory :plane_cost_category do
    sequence(:name) {|n| "plane_cost_category #{n} #{DateTime.now}" }
  end

  factory :plane_cost_category_membership do
    valid_from 1.year.ago.to_date
    valid_to 1.year.from_now.to_date
    plane
    lane_cost_category
  end

  factory :legal_plane_class do
    sequence(:name) { |n| "plane class #{n} #{DateTime.now}" }
  end
end
