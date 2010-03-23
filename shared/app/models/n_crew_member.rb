# A "crew member" that consists of one or more
# passengers (+1, +2, +3 ...)
class NCrewMember < CrewMember
  include NCrewMemberAddition
  def n=(i)
    raise ImmutableObjectException unless n.nil?
    write_attribute(:n, i)
  end
end

