# A pilot that does not have a valid license
# for a flight. If there is no instructor on the
# plane, he is PICUS (pilot in command under supervision).
class Trainee < PersonCrewMember

  #default_scope includes(:person)
  
  def short
    ""
  end
end