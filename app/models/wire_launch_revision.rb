class WireLaunchRevision < LaunchRevision
  include UuidHelper
  acts_as_revision
end
