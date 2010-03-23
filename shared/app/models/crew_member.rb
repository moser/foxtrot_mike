class CrewMember < ActiveRecord::Base
  include UuidHelper
  belongs_to :flight
  
  include CrewMemberAddition
  
  
  def flight=(obj)
    raise ImmutableObjectException unless flight.nil?
    write_attribute(:flight_id, obj.id)
  end
end
