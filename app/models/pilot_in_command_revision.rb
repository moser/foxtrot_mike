class PilotInCommandRevision < PersonCrewMemberRevision
  acts_as_revision
  include UuidHelper
end
