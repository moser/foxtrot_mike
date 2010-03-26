class PilotInCommand < PersonCrewMember
  include PilotInCommandAddition
  
  def to_s
    person.to_s + " (PIC)"
  end
end
