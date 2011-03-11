class CrewMember < ActiveRecord::Base
  include UuidHelper
  include Immutability
  
  has_paper_trail :meta => { :abstract_flight_id => Proc.new { |cm| cm.abstract_flight_id unless cm.nil? || cm.new_record? || cm.abstract_flight_id.nil? } }
  
  belongs_to :abstract_flight
  belongs_to :person
  immutable :abstract_flight
  
  def short
    ''
  end
end
