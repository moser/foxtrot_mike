Factory.define :person do |p|
  p.lastname 'foo'
  p.firstname 'bar'
end

Factory.define :flight do |p|
  p.departure DateTime.now
  p.duration 1
end

Factory.define :plane do |p|
  p.registration "D-1234"
end
