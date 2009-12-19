class Flight < ActiveRecord::Base
  #server side
  if RAILS_ENV
    include SoftValidation::Validation
    soft_validates_presence_of 1, :duration
    soft_validates_presence_of 1, :departure
    acts_as_revisable
  end
  
  belongs_to :plane
  belongs_to :crew
  belongs_to :launch
  belongs_to :from, :class_name => "Airfield"
  belongs_to :to, :class_name => "Airfield"
  
  def arrival
    self.departure + self.duration.minutes rescue nil
  end
  
  def arrival=(time)
    if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include? time.class
      time = time.to_datetime
      unless self.departure.nil?
        self.duration = rational_day_to_minutes(time - self.departure.to_datetime)
      else
        self.departure = time
        self.duration = 0
      end
    end
  end
  
  def departure=(time)
    if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include? time.class
      time = time.to_datetime.utc
      unless self.departure.nil? || self.duration.nil?
        delta = rational_day_to_minutes(self.departure.to_datetime - time)
        self.duration = self.duration + delta
      end
      write_attribute(:departure, time)
    end
  end
  
  
  
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
  
protected
  def rational_day_to_minutes(r)
    (r * 1440).to_i
  end
end
