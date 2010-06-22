#TODO create AbstractFlight, let Flight and TowFlight inherit

class AbstractFlight < ActiveRecord::Base
  Purposes = ['training', 'exercise', '', nil] 
  include UuidHelper
  
  belongs_to :plane
  #launch == nil <=> selflaunched
  has_one :launch, :dependent => :destroy #, :autosave => true
  has_many :crew_members, :dependent => :destroy  # , :autosave => true
  belongs_to :from, :class_name => "Airfield"
  belongs_to :to, :class_name => "Airfield"
  belongs_to :controller, :class_name => "Person"
  
  #accepts_nested_attributes_for :crew_members
  #accepts_nested_attributes_for :launch
  
  #added methods may rely on associations
  include AbstractFlightAddition
  
  #TODO validate crew members
  # exactly one PIC/PICUS
  validates_inclusion_of :purpose, :in => Purposes

  
  #TODO move to module
  accepts_string_for :plane, :parent_method => 'registration'
  accepts_string_for :from, :parent_method => ['registration', 'name']
  accepts_string_for :to, :parent_method => ['registration', 'name']
  
  def cost
    @cost ||= FlightCost.new(self)
  end
  
  def cost_responsible

    seat1.nil? ? nil : seat1.person
  end
  
  def arrival
    unless departure.nil? || duration.nil? || duration == 0
      departure + duration.minutes
    end
  end
  
  def arrival=(time)
    #if time.respond to "to_datetime"
    if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include? time.class
      time = time.to_datetime.utc
      unless self.departure.nil?
        self.duration = rational_day_to_minutes(time - self.departure.to_datetime)
      else #won't happen
        self.departure = time
        self.duration = 0
      end
    end
  end
  
  def departure_date
    self.departure.to_date #rescue nil
  end
  
  def departure_date=(date)
    date = date.to_date
    if self.departure.nil? #won't happen
      self.departure = date
    else
      self.departure = DateTime.new(date.year, date.month, date.day, departure.hour, departure.min, 0, 0)
    end
  end
  
  def departure_time
    departure.hour * 60 + departure.min
  end
  
  def departure_time=(i)
    self.departure = DateTime.now if self.departure.nil? #won't happen
    self.departure = DateTime.new(departure.year, departure.month, departure.day, 0, 0, 0, 0) + i.minutes
  end
  
  def arrival_time
    unless arrival.nil?
      arrival.hour * 60 + arrival.min
    end
  end
  
  def arrival_time=(i)
    unless i.nil?
      self.arrival = DateTime.new(departure.year, departure.month, departure.day + (i < departure_time ? 1 : 0), 0, 0, 0, 0) + i.minutes
    else
      self.duration = 0
    end
  end
  
  def departure=(time)
    if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include? time.class
      time = time.to_datetime.utc
      #unless self.departure.nil? || self.duration.nil?
      #  delta = rational_day_to_minutes(self.departure.to_datetime - time)
      #  self.duration = self.duration + delta if delta.abs < 1440
      #end
      write_attribute(:departure, DateTime.new(time.year, time.month, time.day, time.hour, time.min, 0, 0))
    end
  end
  
  def duration=(i)
    i = i.to_i unless i.is_a? Integer
    i = i.abs
    i = i % 1440 #no flights > 24h
    write_attribute(:duration, i)
  end


  def seat1
    crew_members.find_all { |m| [ PilotInCommand, Trainee ].include?(m.class) }.first
  end
  
  def seat2
    crew_members.find_all { |m| [ Instructor, PersonCrewMember, NCrewMember ].include?(m.class) }.first
  end
  
  def seat1_id
    seat1.person_id rescue nil
  end
  
  def seat2_id
    seat2.person_id rescue nil
  end
  
  def seat1_id=(id)
    self.seat1 = id
  end
  
  def seat2_id=(id)
    self.seat2 = id
  end
  
  def seat1=(obj)
    unless obj.nil?
      obj = Person.find(obj) unless obj.is_a?(Person)
      old = seat1
      if obj.trainee?(self)
        new = Trainee.new(:person => obj)
      else
        new = PilotInCommand.new(:person => obj)
      end
      if !new.equals?(old)
        crew_members.delete old unless old.nil?
        new.save
        crew_members << new
      end
    else
      old = seat1
      crew_members.delete old unless old.nil?
    end
    unless seat2.nil? #check if this one should be changed by reassigning it
      if seat2.is_a?(PersonCrewMember) #don't need to check if seat2 is a number (NCrewMember)
        self.seat2 = seat2.person
      end
    end
  end
  
  def seat2=(obj)
    unless obj.nil?
      obj = Person.find(obj) unless obj.is_a?(Person) || obj.is_a?(Integer)
      old = seat2
      if obj.is_a?(Person)
        if seat1.is_a?(Trainee) && obj.instructor?(self)
          new = Instructor.new(:person => obj)
        else #we do allow other people to fly with trainees, but should warn about that
          new = PersonCrewMember.new(:person => obj)
        end
      else
        new = NCrewMember.new(:n => obj)
      end
      if !new.equals?(old)
        crew_members.delete old unless old.nil?
        new.save
        crew_members << new
      end
    else
      old = seat2
      crew_members.delete old unless old.nil?
    end
  end
  
  def pic
    if seat1.is_a?(PilotInCommand) || (seat1.is_a?(Trainee) && seat2.nil?)
      seat1
    else
      seat2
    end
  end
  
  def crew_members_attributes=(attrs)
    unless attrs.nil?
      attrs.each do |h|
        obj = h.delete(:type).constantize.new(h)
        obj.id = h[:id]
        obj.save
        crew_members << obj
      end
    end
  end
 
  def launch_attributes=(attrs)
    unless attrs.nil?
      obj = attrs.delete(:type).constantize.new(attrs)
      obj.id = attrs[:id]
      obj.save
    end
  end

  def self.shared_attribute_names
    [ :plane_id, :from_id, :to_id, :departure, :duration, :engine_duration,
      :purpose, :comment, :id, :type ]
  end
  
  def shared_attributes
    a = self.attributes.reject { |k, v| !self.class.shared_attribute_names.include?(k.to_sym) }
    a[:crew_members_attributes] = crew_members.map { |m| m.attributes }
    a[:launch_attributes] = launch.attributes unless launch.nil?
    a[:type] = self.class.to_s if a[:type].nil?
    a
  end  
  
  def history
    #TODO add manual cost?
    #[revisions, [PilotInCommandRevision, TraineeRevision, PersonCrewMemberRevision,
    #  NCrewMemberRevision, WireLaunchRevision, TowLaunchRevision].map { |c| c.find(:all, :conditions => { :abstract_flight_id => id }) }].flatten.sort_by { |r| r.revisable_current_at }
  end
  
protected
  def rational_day_to_minutes(r)
    (r * 1440).to_i
  end
end
