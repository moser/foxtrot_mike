Factory.define :flight do |p|
  p.association :plane, :factory => :plane
  p.association :seat1, :factory => :person
  p.association :controller, :factory => :person
  p.association :from, :factory => :airfield
  p.association :to, :factory => :airfield
  #p.departure { 20.minutes.ago }
  p.departure_i 10
  p.arrival_i 11
end

Factory.define :non_editable_flight, :class => Flight do |p|
  p.association :plane, :factory => :plane
  p.association :seat1, :factory => :person
  p.association :controller, :factory => :person
  p.association :from, :factory => :airfield
  p.association :to, :factory => :airfield
  p.departure_date { Date.today }
  p.departure_i 10
  p.arrival_i 11
  p.after_create do |flight|
    flight.accounting_session = AccountingSession.generate!
    flight.save
    flight.accounting_session.finished_at = 1.day.ago
    flight.accounting_session.save!
  end
end

Factory.define :tow_flight do |p|
  p.association :plane, :factory => :plane
  p.association :seat1, :factory => :person
  p.association :controller, :factory => :person
  p.association :from, :factory => :airfield
  p.association :to, :factory => :airfield
  p.association :abstract_flight, :factory => :flight
  p.departure_i 10
  p.arrival_i 11
end

Factory.define :abstract_flight do |p|
  p.departure_date { Date.today }
  p.departure_i 10
  p.arrival_i 11
end
