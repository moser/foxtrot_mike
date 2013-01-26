class Liability < ActiveRecord::Base
  include UuidHelper
  include ImmutableFlight

  flight_relation :flight

  after_save :invalidate_flight
  after_destroy :invalidate_flight

  belongs_to :flight
  belongs_to :person

  validates_presence_of :flight, :person, :proportion
  validates_numericality_of :proportion, :greater_than => 0
  
  def value
    flight.value_for(self)
  end

  def default?
    false
  end

private
  def invalidate_flight
    flight.invalidate_accounting_entries
  end
end
