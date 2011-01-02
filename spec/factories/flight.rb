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
