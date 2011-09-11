class PilotInCommand < PersonCrewMember
  #default_scope includes(:person)

  def pic?
    true
  end
end
