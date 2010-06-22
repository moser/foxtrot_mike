class PilotInCommand < PersonCrewMember
  include PilotInCommandAddition
  
  def short
    #TODO i18n
    "PIC"
  end
end
