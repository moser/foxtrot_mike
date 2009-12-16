Factory.define :flight do |p|
  #p.crew Factory(:crew)
  p.departure DateTime.now
  p.duration 1
end
