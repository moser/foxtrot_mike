class PersonCrewMember < CrewMember
  belongs_to :person
  
  include PersonCrewMemberAddition
  
  def person=(obj)
    raise ImmutableObjectException unless person.nil?
    write_attribute(:person_id, obj.id)
  end
end
