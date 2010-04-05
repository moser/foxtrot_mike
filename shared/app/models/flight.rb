class Flight < ActiveRecord::Base
  include UuidHelper
  
  belongs_to :plane
  #launch == nil <=> selflaunched
  has_one :launch, :dependent => :destroy #, :autosave => true
  has_many :crew_members, :dependent => :destroy  # , :autosave => true
  belongs_to :from, :class_name => "Airfield"
  belongs_to :to, :class_name => "Airfield"
  
  #accepts_nested_attributes_for :crew_members
  #accepts_nested_attributes_for :launch
  
  #added methods may rely on associations
  include FlightAddition
  
  #TODO validate crew members
  # exactly one PIC/PICUS
  
  accepts_string_for :plane, :parent_method => 'registration'
  accepts_string_for :from, :parent_method => ['registration', 'name']
  accepts_string_for :to, :parent_method => ['registration', 'name']
  
  def cost
    FlightCost.new(self) unless cost_responsible.nil?
  end
  
  def cost_responsible

    seat1.nil? ? nil : seat1.person
  end
  
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
  
  def departure_date
    self.departure.to_date #rescue nil
  end
  
  def departure_date=(date)
    date = date.to_date
    if self.departure.nil?
      self.departure = date
    else
      self.departure = DateTime.new(date.year, date.month, date.day, departure.hour, departure.min, departure.sec, 0)
    end
  end
  
  def departure=(time)
    if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include? time.class
      time = time.to_datetime.utc
      #unless self.departure.nil? || self.duration.nil?
      #  delta = rational_day_to_minutes(self.departure.to_datetime - time)
      #  self.duration = self.duration + delta if delta.abs < 1440
      #end
      write_attribute(:departure, time)
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
    unless seat2.nil? #check if this one should be changed by reassigning it
      if seat2.is_a?(PersonCrewMember) #don't need to check if seat2 is a number (NCrewMember)
        self.seat2 = seat2.person
      end
    end
    
  end
  
  def seat2=(obj)
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
        obj = h[:type].constantize.new(h)
        obj.id = h[:id]
        obj.save
        crew_members << obj
      end
    end
  end
  
  def launch_attributes=(attrs)
    
  end
  
=begin
  def crew_attributes=(attributes)
    [1,2].each do |i|
      id = attributes["seat#{i}_id"]
      name = attributes["seat#{i}_name"]
      obj = Person.find_by_id(id)
      if (obj.nil? || !obj.name?(name)) && !name.nil?
        #name given, but no id
        obj = Person.find_by_name(name)
      end
      attributes["seat#{i}"] = obj
    end
    unless attributes["seat1"].nil?
      if attributes["seat1"].trainee?(self)
        c = TrainingCrew.new
        c.trainee = attributes["seat1"]
        c.instructor = attributes["seat2"]
      else
        c = StandardCrew.new
        c.pic = attributes["seat1"]
        if attributes["seat2"].nil?
          m = /\+([0-9]+)/.match(attributes["seat2_name"])
          c.passengers = m[1] unless m.nil?
        else
          c.co = attributes["seat2"]
        end
      end
      self.crew = c
    else
      self.crew = nil
    end
  end
=end

  def self.shared_attribute_names
    [  :plane_id, :from_id, :to_id, :departure, :duration, :engine_duration,
      :purpose, :comment ] #:id, , :type
  end
  
  def shared_attributes
    a = self.attributes.reject { |k, v| !self.class.shared_attribute_names.include?(k.to_sym) }
    a[:crew_members_attributes] = crew_members.map { |m| m.attributes }
    a[:launch_attributes] = launch.attributes unless launch.nil?
    a
  end 
  
  def self.l(sym = nil)
    if sym.nil?
      human_name
    else
      human_attribute_name(sym)
    end
  end

    
protected
  def rational_day_to_minutes(r)
    (r * 1440).to_i
  end
end
