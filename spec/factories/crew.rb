Factory.define :crew, :class => PICAndXCrew do |c|
  c.pic Factory(:person)
end
