class CrewMemberRevision < ActiveRecord::Base
  acts_as_revision :clone_associations => :all
  include UuidHelper
end
