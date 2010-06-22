class Liability < ActiveRecord::Base
  include UuidHelper
  belongs_to :flight
  belongs_to :person
  
  include LiabilityAddition
  
  def value
    flight.value_for(self)
  end
end
