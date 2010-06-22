class FlightRevision < AbstractFlightRevision
  acts_as_revision
  include UuidHelper
end
