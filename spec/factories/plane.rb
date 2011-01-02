Factory.define :plane do |p|
  p.sequence(:registration) {|n| "D-#{n} #{DateTime.now}" }
  p.association :group, :factory => :group
  p.association :legal_plane_class, :factory => :legal_plane_class
end

Factory.define :plane_cost_category do |c|
  c.sequence(:name) {|n| "plane_cost_category #{n} #{DateTime.now}" }
end

Factory.define :plane_cost_category_membership do |m|
  m.valid_from 1.year.ago.to_date
  m.valid_to 1.year.from_now.to_date
  m.association :plane, :factory => :plane
  m.association :plane_cost_category, :factory => :plane_cost_category
end

Factory.define :legal_plane_class do |c|
  c.sequence(:name) { |n| "plane class #{n} #{DateTime.now}" }
end
