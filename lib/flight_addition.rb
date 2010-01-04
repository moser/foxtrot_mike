module FlightAddition
  include SoftValidation::Validation
  soft_validates_presence_of 1, :duration
  soft_validates_presence_of 1, :departure
  
  def self.included(base) #:nodoc:
    base.acts_as_revisable
  end
end
