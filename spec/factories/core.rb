#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

unless defined?(FACTORY_DEFINED)
  FACTORY_DEFINED = true

  Factory.define :group do |g|
    g.sequence(:name) { |n| "Group #{n} #{DateTime.now}" }
  end

  Factory.define :legal_plane_class do |c|
    c.sequence(:name) { |n| "plane class #{n} #{DateTime.now}" }
  end

  Factory.define :person do |p|
    p.lastname 'foo'
    p.firstname 'bar'
    p.association :group, :factory => :group
  end

  Factory.define :airfield do |a|
    a.sequence(:name) {|n| "Airfield #{n} #{DateTime.now}" }
    a.sequence(:registration) {|n| "#{n} #{DateTime.now}" }
  end

  Factory.define :flight do |p|
    p.association :plane, :factory => :plane
    p.association :seat1, :factory => :person
    p.association :controller, :factory => :person
    p.association :from, :factory => :airfield
    p.association :to, :factory => :airfield
    p.departure { 20.minutes.ago }
    p.duration 1
  end

  Factory.define :tow_flight do |p|
    p.association :plane, :factory => :plane
    p.association :seat1, :factory => :person
    p.association :controller, :factory => :person
    p.association :from, :factory => :airfield
    p.association :to, :factory => :airfield
    p.association :abstract_flight, :factory => :flight
    p.duration 1
  end

  Factory.define :abstract_flight do |p|
    p.departure { 20.minutes.ago }
    p.duration 1
  end


  Factory.define :plane do |p|
    p.sequence(:registration) {|n| "D-#{n} #{DateTime.now}" }
    p.association :group, :factory => :group
    p.association :legal_plane_class, :factory => :legal_plane_class
  end

  Factory.define :plane_cost_category do |c|
    c.sequence(:name) {|n| "plane_cost_category #{n} #{DateTime.now}" }
    c.tow_cost_rule_type "TimeCostRule"
  end

  Factory.define :person_cost_category do |c|
    c.sequence(:name) {|n| "person_cost_category #{n} #{DateTime.now}" }
  end

  Factory.define :wire_launcher_cost_category do |c|
    c.sequence(:name) {|n| "wire_launcher_cost_category #{n} #{DateTime.now}" }
  end

  Factory.define :person_cost_category_membership do |m|
    m.valid_from 1.year.ago.to_date
    m.valid_to 1.year.from_now.to_date
    m.association :person, :factory => :person
    m.association :person_cost_category, :factory => :person_cost_category
  end

  Factory.define :plane_cost_category_membership do |m|
    m.valid_from 1.year.ago.to_date
    m.valid_to 1.year.from_now.to_date
    m.association :plane, :factory => :plane
    m.association :plane_cost_category, :factory => :plane_cost_category
  end

  Factory.define :wire_launcher_cost_category_membership do |m|
    m.valid_from 1.year.ago.to_date
    m.valid_to 1.year.from_now.to_date
    m.association :wire_launcher, :factory => :wire_launcher
    m.association :wire_launcher_cost_category, :factory => :wire_launcher_cost_category
  end

  Factory.define :time_cost_rule do |r|
    r.sequence(:name) { |n| "time_cost_rule #{n} #{DateTime.now}" }
    r.cost 1
    r.depends_on "duration"
    r.valid_from 1.month.ago.to_date
    r.flight_type "Flight"
    r.association :plane_cost_category, :factory => :plane_cost_category
    r.association :person_cost_category, :factory => :person_cost_category
  end

  Factory.define :wire_launch_cost_rule do |r|
    r.sequence(:name) { |n| "wire_launch_cost_rule #{n} #{DateTime.now}" }
    r.cost 1
    r.valid_from 1.month.ago.to_date
    r.association :wire_launcher_cost_category, :factory => :wire_launcher_cost_category
    r.association :person_cost_category, :factory => :person_cost_category
  end

  Factory.define :wire_launcher do |p|
    p.sequence(:registration) {|n| "BY-#{n} #{DateTime.now}" }
  end

end
