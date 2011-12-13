class UnknownCrewMember < PilotInCommand
  def person
    @person ||= UnknownPerson.new
  end

  def unknown?
    true
  end

  def person_id
    "unknown"
  end
end
