class InstructorRevision < PilotInCommandRevision
  acts_as_revision
  include UuidHelper
end
