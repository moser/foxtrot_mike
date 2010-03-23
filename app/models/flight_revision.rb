class FlightRevision < ActiveRecord::Base
  acts_as_revision
  include UuidHelper
end
