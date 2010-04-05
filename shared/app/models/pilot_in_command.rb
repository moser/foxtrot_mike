class PilotInCommand < PersonCrewMember
  include PilotInCommandAddition
  
  def to_s
    person.to_s
  end
  
  def short
    #TODO i18n
    "PIC"
  end
end
