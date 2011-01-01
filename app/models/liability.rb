class Liability < ActiveRecord::Base
  include UuidHelper

  has_paper_trail :meta => { :abstract_flight_id => Proc.new { |l| l.flight_id unless l.nil? || l.new_record? || l.flight_id.nil? } }  

  belongs_to :flight
  belongs_to :person

  validates_presence_of :flight, :person, :proportion
  validates_numericality_of :proportion, :greater_than => 0
  
  def value
    flight.value_for(self)
  end
end
