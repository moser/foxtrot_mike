class Crew < ActiveRecord::Base
  has_one :flight
  attr_accessor :seat1, :seat2
    
  def self.create(attributes = nil)
    crew = Crew.new attributes
    crew
  end
  
  def self.new(attributes = nil)
    
    if !attributes.nil? && attributes[:seat1].is_a? Person && 
      crew = TrainingCrew.new attributes
    else
      crew = PICAndXCrew.new attributes
    end
    crew
  end
end
