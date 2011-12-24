class PersonCrewMember < CrewMember
  include Immutability

  validates_presence_of :person
  immutable :person

  def to_s
    person.to_s
  end

  def equals?(other)
    self.class == other.class && person == other.person
  end

  def value
    person
  end

  def person?
    true
  end

  def link_to_value(context)
    context.show_link(person, person.name, :class => "facebox")
  end
end
