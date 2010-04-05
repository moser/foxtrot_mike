require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

Factory.define :group do |g|
  g.name 'some_group'
end

Factory.define :person do |p|
  p.lastname 'foo'
  p.firstname 'bar'
  p.association :group, :factory => :group
end

Factory.define :flight do |p|
  p.departure { 20.minutes.ago }
  p.duration 1
end


Factory.define :plane do |p|
  p.registration "D-1234"
end

Factory.define :plane_cost_category do |c|
  c.name "plane_cost_category"
  c.tow_cost_rule_type ""
end

Factory.define :person_cost_category do |c|
  c.name "person_cost_category"
end

Factory.define :person_cost_category_membership do |m|
  m.valid_from 1.year.ago
  m.valid_to 1.year.from_now
  m.association :person, :factory => :person
  m.association :person_cost_category, :factory => :person_cost_category
end

Factory.define :plane_cost_category_membership do |m|
  m.valid_from 1.year.ago
  m.valid_to 1.year.from_now
  m.association :plane, :factory => :plane
  m.association :plane_cost_category, :factory => :plane_cost_category
end

Factory.define :time_cost_rule do |r|
  r.name "time_cost_rule"
  r.cost 1
  r.depends_on "duration"
  r.valid_from 1.month.ago
end