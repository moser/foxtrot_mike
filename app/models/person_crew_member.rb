class PersonCrewMember < CrewMember  

  validates_presence_of :person
  
  #default_scope includes(:person)

  def person=(obj)
    raise ImmutableObjectException unless person.nil?
    write_attribute(:person_id, obj.id) unless obj.nil?
  end
  
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
