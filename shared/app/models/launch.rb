class Launch < ActiveRecord::Base
  include UuidHelper
  belongs_to :abstract_flight
  include LaunchAddition
  #TODO ImmutableObjectException?
end
