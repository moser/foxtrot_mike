class Liability < ActiveRecord::Base
  include UuidHelper
  belongs_to :flight
  belongs_to :person
  
  include LiabilityAddition

  validates_presence_of :flight, :person, :proportion
  validates_numericality_of :proportion, :greater_than => 0
  
  def value
    flight.value_for(self)
  end
end
