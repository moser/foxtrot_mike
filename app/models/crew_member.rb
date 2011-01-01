class CrewMember < ActiveRecord::Base
  include UuidHelper
  
  has_paper_trail :meta => { :abstract_flight_id => Proc.new { |cm| cm.abstract_flight_id unless cm.nil? || cm.new_record? || cm.abstract_flight_id.nil? } }
  
  belongs_to :abstract_flight
  belongs_to :person
  
  def abstract_flight=(obj)
    raise ImmutableObjectException unless abstract_flight.nil?
    write_attribute(:abstract_flight_id, obj.id)
  end
  
  def short
    ''
  end
end
