#TODO create AbstractFlight, let Flight and TowFlight inherit
require "digest/sha2"

class AbstractFlight < ActiveRecord::Base
  #Purposes = ['training', 'exercise', 'tow', nil] 
  include UuidHelper
  before_save :destroy_launch

  belongs_to :plane
  #launch == nil <=> selflaunched
  belongs_to :launch, :polymorphic => true, :autosave => true
  has_one :manual_cost, :as => :item
  has_many :crew_members, :include => [:person] #, :dependent => :destroy  # , :autosave => true
  belongs_to :from, :class_name => "Airfield"
  belongs_to :to, :class_name => "Airfield"
  belongs_to :controller, :class_name => "Person"
  
  #accepts_nested_attributes_for :crew_members
  #accepts_nested_attributes_for :launch
  
  has_paper_trail # :meta => { :abstract_flight_id => Proc.new { |flight| flight.id } }
  send(:include, SoftValidation::Validation)
  soft_validates_presence_of 1, :duration
  soft_validates_presence_of 1, :departure
  soft_validate 1 do |r|
    r.problems['crew_members'] = 'No Crew specified' if r.crew_members.size == 0
  end
  
  def all_versions
    (versions + Version.where(:abstract_flight_id => id)).sort_by { |e| e.created_at }
  end
  
  def all_changes
    all_versions.select { |version| version.event != "create" }
  end
  
  #TODO validate crew members
  # exactly one PIC/PICUS
  #validates_inclusion_of :purpose, :in => Purposes
  validates_presence_of :plane
  validates_presence_of :departure
  validates_presence_of :seat1_id
  validates_presence_of :controller
  validates_presence_of :from
  validates_presence_of :to
  
  #TODO move to module
  accepts_string_for :plane, :parent_method => 'registration'
  accepts_string_for :from, :parent_method => ['registration', 'name']
  accepts_string_for :to, :parent_method => ['registration', 'name']
  
  def initialize(*args)
    super
    if new_record?
      self.duration ||= -1
    end
  end

#  def launch_type
#    I18n.t("activerecord.attributes.flight.launch_types.#{ launch.nil? ? "self" : launch.class.to_s.underscore }.long")
#  end

  def launch_type_short
    I18n.t("activerecord.attributes.flight.launch_types.#{ launch.nil? ? "self" : launch.class.to_s.underscore }.short")
  end
  
#  def cost
#    @cost ||= FlightCost.new(self)
#  end

  def cost
    candidates = FlightCostRule.for(self).map { |cr| cr.apply_to(self) }
    candidates = candidates.sort_by { |a| a.free_sum }
    candidates.first
  end

  def launch_cost
    unless launch.nil?
      launch.cost
    end
  end

  def cost_sum
    [ (cost || Cost.new(nil)), (launch_cost || Cost.new(nil)) ].map { |c| c.sum }.sum
  end

  def free_cost_sum
    [ (cost || Cost.new(nil)), (launch_cost || Cost.new(nil)) ].map { |c| c.free_sum }.sum
  end
  
  def cost_responsible
    seat1.nil? ? nil : seat1.person
  end
  
  def engine_duration
    unless plane.nil?
      if !plane.has_engine
        0
      elsif !plane.can_fly_without_engine
        duration
      else
        read_attribute(:engine_duration)
      end
    end
  end
  
  def arrival
    unless departure.nil? || duration.nil? || duration < 0
      departure + duration.minutes
    end
  end
  
  def arrival=(time)
    #if time.respond to "to_datetime"
    if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include? time.class
      time = time.to_datetime.utc
      unless departure.nil?
        self.duration = rational_day_to_minutes(time - self.departure.to_datetime)
      else #won't happen
        self.departure = time
        self.duration = 0
      end
    end
  end
  
  def departure_date
    departure.to_date #rescue nil
  end
  
  def departure_date=(date)
    date = date.to_date
    if departure.nil? #won't happen
      self.departure = date
    else
      self.departure = DateTime.new(date.year, date.month, date.day, departure.hour, departure.min, 0, 0)
    end
  end
  
  def departure_day_time
    @departure_day_time ||= DayTime.new(departure_time)
    @departure_day_time.minutes = departure_time
    @departure_day_time
  end
  
  def departure_time
    departure.hour * 60 + departure.min
  end
  
  def departure_time=(i)
    self.departure = DateTime.now if departure.nil? #won't happen
    self.departure = DateTime.new(departure.year, departure.month, departure.day, 0, 0, 0, 0) + i.minutes
  end
  
  def arrival_day_time
    @arrival_day_time ||= DayTime.new(arrival_time)
    @arrival_day_time.minutes = arrival_time
    @arrival_day_time
  end
  
  def arrival_time
    unless arrival.nil?
      arrival.hour * 60 + arrival.min
    end
  end
  
  def arrival_time=(i)
    unless i.nil?
      self.arrival = DateTime.new(departure.year, departure.month, departure.day, 0, 0, 0, 0) + i.minutes + (i < departure_time ? 1 : 0).days
    else
      self.duration = -1
    end
  end
  
  def departure=(time)
    if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include? time.class
      time = time.to_datetime.utc
      unless departure.nil? || duration.nil? || duration < 0
        delta = rational_day_to_minutes(self.departure.to_datetime - time)
        self.duration = duration + delta if delta.abs < 1440
      end
      write_attribute(:departure, DateTime.new(time.year, time.month, time.day, time.hour, time.min, 0, 0))
    end
  end
  
  def duration_time_span
    @duration_time_span ||= TimeSpan.new(duration)
    @duration_time_span.minutes = duration
    @duration_time_span
  end
  
  # Any negative duration means that a flight has not ended yet
  def duration=(i)
    i = i.to_i unless i.is_a? Integer
    i = -1 if i < 0
    i = i % 1440 unless i < 0 #no flights > 24h
    write_attribute(:duration, i)
  end
  
  def landed?
    !duration.nil? && duration >= 0 #there are flights with duration 0 minutes
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
    self.seat1 = (id != '' ? id : nil)
  end
  
  def seat2_id=(id)
    self.seat2 = (id != '' ? id : nil)
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
    a[:launch_attributes] = launch.shared_attributes unless launch.nil?
    a[:type] = self.class.to_s if a[:type].nil?
    a
  end

  def purpose
    if seat1.is_a?(Trainee)
      Purpose.new('training')
    else
      Purpose.new('exercise')
    end 
  end
  
  def history
    #TODO add manual cost?
    #[revisions, [PilotInCommandRevision, TraineeRevision, PersonCrewMemberRevision,
    #  NCrewMemberRevision, WireLaunchRevision, TowLaunchRevision].map { |c| c.find(:all, :conditions => { :abstract_flight_id => id }) }].flatten.sort_by { |r| r.revisable_current_at }
  end

  def group_id
    Digest::SHA256.hexdigest(((crew_members.sort_by { |c| c.class.to_s }).map {|m| m.person_id + m.class.name}).join + "#{departure_date}")
  end

  def grouping_purposes
    [purpose]
  end
  
  def grouping_planes
    [plane]
  end

  def grouping_people
    crew_members.select { |m| [ PilotInCommand, Trainee, Instructor ].include?(m.class) }.map(&:person).reject(&:'nil?')
  end

  def grouping_licenses
    grouping_people.map { |p| p.relevant_licenses_for(self).first }.reject(&:'nil?')
  end

  def grouping_people_groups
    grouping_people.map(&:group).uniq
  end

  def grouping_groups
    unless plane
      grouping_people_groups
    else
      (grouping_people_groups + [plane.group]).uniq
    end
  end

  def sort
    departure.to_i
  end

  def self.include_all
    includes(:plane, :from, :to, :crew_members)
  end

  def self.latest_departure(rel = AbstractFlight)
    rel.order('departure DESC').limit(1).first.departure rescue DateTime.now
  end
  
  def self.oldest_departure(rel = AbstractFlight)
    rel.order('departure ASC').limit(1).first.departure rescue DateTime.now
  end
  
protected
  def rational_day_to_minutes(r)
    (r * 1440).to_i
  end

private
  def destroy_launch
    if changes.keys.include?("launch_type") && changes.keys.include?("launch_id")
      old_type = changes[:launch_type][0]
      if old_type
        #old_type.constantize.find(changes[:launch_id][0]).destroy
        old_type.constantize.where(:id => changes[:launch_id][0]).destroy_all
      end
    end
  end
end
