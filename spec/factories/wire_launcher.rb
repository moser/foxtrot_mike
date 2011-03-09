Factory.define :wire_launcher_cost_category_membership do |m|
  m.valid_from 1.year.ago.to_date
  m.valid_to 1.year.from_now.to_date
  m.association :wire_launcher, :factory => :wire_launcher
  m.association :wire_launcher_cost_category, :factory => :wire_launcher_cost_category
end

Factory.define :wire_launcher do |p|
  p.sequence(:registration) {|n| "BY-#{n} #{DateTime.now}" }
  p.financial_account { FinancialAccount.generate! }
end

Factory.define :wire_launcher_cost_category do |c|
  c.sequence(:name) {|n| "wire_launcher_cost_category #{n} #{DateTime.now}" }
end

Factory.define :wire_launch do |w|
  w.association :wire_launcher, :factory => :wire_launcher
  w.association :abstract_flight, :factory => :flight
end
