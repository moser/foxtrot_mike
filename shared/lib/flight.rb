class Flight < ActiveRecord::Base
  include FlightAddition
  include UUIDHelper
  
  belongs_to :plane
  belongs_to :launch
  belongs_to :crew1, :class_name => "Person"
  belongs_to :crew2, :class_name => "Person"
  belongs_to :from, :class_name => "Airfield"
  belongs_to :to, :class_name => "Airfield"
  
  accepts_string_for :plane, :parent_method => 'registration'
  accepts_string_for :crew1, :ignore_case => false, :create => false
  accepts_string_for :crew2, :ignore_case => false, :create => false
  
  def arrival
    self.departure + self.duration.minutes rescue nil
  end
  
  def arrival=(time)
    if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include? time.class
      time = time.to_datetime.utc
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
    
protected
  def rational_day_to_minutes(r)
    (r * 1440).to_i
  end
end
