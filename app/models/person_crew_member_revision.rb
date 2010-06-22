class PersonCrewMemberRevision < CrewMemberRevision
  acts_as_revision
  include UuidHelper
end
