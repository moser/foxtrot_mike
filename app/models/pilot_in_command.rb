class PilotInCommand < PersonCrewMember
  #default_scope includes(:person)
  
  def short
    #TODO i18n
    "PIC"
  end
end
