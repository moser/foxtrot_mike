class CrewMember < ActiveRecord::Base
  include UuidHelper
  include Immutability
  
  has_paper_trail :meta => { :abstract_flight_id => Proc.new { |cm| cm.abstract_flight_id unless cm.nil? || cm.new_record? || cm.abstract_flight_id.nil? } }
  
  belongs_to :abstract_flight
  belongs_to :person
  immutable :abstract_flight

  def other
    (abstract_flight && abstract_flight.crew_members.reject { |e| e == self }) || []
  end

  def short
    if picus?
      "PICUS"
    elsif pic?
      "PIC"
    else
      ""
    end
  end

  def size
    1
  end

  def trainee?
    false
  end

  def instructor?
    false
  end

  def pic?
    false
  end

  def picus?
    trainee? && pic?
  end
end
