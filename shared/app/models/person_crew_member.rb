class PersonCrewMember < CrewMember
  belongs_to :person
  
  include PersonCrewMemberAddition
  
  def person=(obj)
    raise ImmutableObjectException unless person.nil?
    write_attribute(:person_id, obj.id)
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
end
