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
  
  def short
    "" #TODO should be a I18n string?
  end

  def value
    person
  end
end
