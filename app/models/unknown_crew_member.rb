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

  def link_to_value(o)
    I18n.t("unknown_person")
  end
end
