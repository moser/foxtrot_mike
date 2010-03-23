class CrewMemberRevision < ActiveRecord::Base
  acts_as_revision
  include UuidHelper
end
