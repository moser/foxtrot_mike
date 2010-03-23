class TraineeRevision < ActiveRecord::Base
  acts_as_revision
  include UuidHelper
end
