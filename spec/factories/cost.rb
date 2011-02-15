Factory.define :cost_rule_condition do |f|
end

Factory.define :financial_account do |f|
  f.sequence(:name) { |n| "fa #{n}" }
end

Factory.define :cost_hint do |f|
  f.sequence(:name) { |n| "CostHint#{n}" }
end

Factory.define :flight_cost_item do |f|
end

Factory.define :flight_cost_rule do |f|
  f.valid_from 1.day.ago
  f.sequence(:name) { |n| "flight_cost_rule #{n} #{DateTime.now}" }
  f.flight_type "Flight"
  f.association :plane_cost_category, :factory => :plane_cost_category
  f.association :person_cost_category, :factory => :person_cost_category
end

Factory.define :wire_launch_cost_item do |f|
end

Factory.define :wire_launch_cost_rule do |r|
  r.sequence(:name) { |n| "wire_launch_cost_rule #{n} #{DateTime.now}" }
  r.valid_from 1.month.ago.to_date
  r.association :wire_launcher_cost_category, :factory => :wire_launcher_cost_category
  r.association :person_cost_category, :factory => :person_cost_category
end

Factory.define(:accounting_session) do |s|
  s.sequence(:name) { |n| "accounting_session #{n} #{DateTime.now}" }
  s.sequence(:end_date) { |n| (500 - n).days.ago }
end
