Factory.define :person do |p|
  p.lastname 'foo'
  p.firstname 'bar'
  p.association :group, :factory => :group
end

Factory.define :person_cost_category do |c|
  c.sequence(:name) {|n| "person_cost_category #{n} #{DateTime.now}" }
end

Factory.define :person_cost_category_membership do |m|
  m.valid_from 1.year.ago.to_date
  m.valid_to 1.year.from_now.to_date
  m.association :person, :factory => :person
  m.association :person_cost_category, :factory => :person_cost_category
end