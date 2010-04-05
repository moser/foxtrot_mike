class Launch < ActiveRecord::Base
  include UuidHelper
  belongs_to :flight
  
  #TODO ImmutableObjectException?
end
