class CrewMember < ActiveRecord::Base
  include UuidHelper
  belongs_to :abstract_flight
  
  include CrewMemberAddition  
  
  def abstract_flight=(obj)
    raise ImmutableObjectException unless abstract_flight.nil?
    write_attribute(:abstract_flight_id, obj.id)
  end
  
  def short
    ''
  end
end
