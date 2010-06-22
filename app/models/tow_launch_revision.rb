class TowLaunchRevision < LaunchRevision
  acts_as_revision
  include UuidHelper
end
