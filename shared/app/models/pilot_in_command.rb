class PilotInCommand < PersonCrewMember
  include PilotInCommandAddition

  #default_scope includes(:person)
  
  def short
    #TODO i18n
    "PIC"
  end
end
