Factory.define :person do |p|
  p.lastname 'foo'
  p.firstname 'bar'
end

Factory.define :crew, :class => PICAndXCrew do |c|
  c.pic { Factory(:person) }
end

Factory.define :flight do |p|
  p.crew { Factory(:crew) }
  p.departure DateTime.now
  p.duration 1
end
