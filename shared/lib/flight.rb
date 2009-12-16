class Flight < ActiveRecord::Base
  #server side
  if RAILS_ENV
    include SoftValidation::Validation
    soft_validates_presence_of :duration
    soft_validates_presence_of :departure
    acts_as_revisable
  end
  
  belongs_to :plane
  belongs_to :crew
  belongs_to :launch
  belongs_to :from, :class_name => "Airfield"
  belongs_to :to, :class_name => "Airfield"
  
  #Accepts:
  #  - a Person object
  #  - an Array of two Persons (PIC or trainee first)
  #  - an Array of a Person (first) and an Integer
  def crew= obj
    if obj.is_a? Array
      if obj[0].is_a? Person
        self.crew = obj[0]
        if obj[1]
          if crew.is_a? TrainingCrew
            crew.update_attributes :instructor => obj[1]
          else
            if obj[1].is_a? Person
              crew.update_attributes :co => obj[1]
            else
              crew.update_attributes :passengers => obj[1]
            end
          end
        end
      end
    elsif obj.is_a? Person
      if obj.trainee?(self)
        c = TrainingCrew.create :trainee => obj
      else
        c = PICAndXCrew.create :pic => obj
      end
      self.crew = c
    elsif obj.is_a? Crew
      self.crew_id = obj.id
    end
  end
end
