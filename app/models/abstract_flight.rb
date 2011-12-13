#TODO create AbstractFlight, let Flight and TowFlight inherit
require "digest/sha2"

class AbstractFlight < ActiveRecord::Base
  #Purposes = ['training', 'exercise', 'tow', nil] 
  include UuidHelper
  before_save :destroy_launch
  before_save :execute_soft_validation

  belongs_to :plane
  #launch == nil <=> selflaunched
  belongs_to :launch, :polymorphic => true, :autosave => true, :readonly => false
  has_one :manual_cost, :as => :item
  has_many :crew_members, :include => [:person], :after_add => :association_changed, :after_remove => :association_changed, :dependent => :destroy  # , :autosave => true
  has_many :accounting_entries, :as => :item
  belongs_to :from, :class_name => "Airfield"
  belongs_to :to, :class_name => "Airfield"
  belongs_to :controller, :class_name => "Person"

  class << self
    def between(from, to)
      if from && to
        where("departure_date >= ? AND departure_date < ?", from, to)
      elsif from
        after(from)
      elsif to
        before(to)
      else
        self.where("1 = 1")
      end
    end

    def after(from)
      where("departure_date >= ?", from)
    end

    def before(to)
      where("departure_date < ?", to)
    end
  end

  #accepts_nested_attributes_for :crew_members
  #accepts_nested_attributes_for :launch

  has_paper_trail :meta => { :abstract_flight_id => Proc.new do |l| 
            unless l.nil? || !l.is_a?(TowFlight) || l.new_record? || l.abstract_flight.nil?
              l.abstract_flight.id  
            end
          end }

  attr_reader :problems
  def soft_validate
    @problems = []
    @problems << :too_many_people if plane && crew_members.map { |e| e.size }.sum > plane.seat_count
    @problems << :seat2_is_not_an_instructor if seat1 && seat1.trainee? && seat2 && !seat2.instructor?
    @problems << :launch_method_impossible if plane && ((!plane.selflaunching? && launch.nil?) ||
                                                        (!plane.can_be_towed && launch.is_a?(TowFlight)) ||
                                                        (!plane.can_be_wire_launched && launch.is_a?(WireLaunch)))
    @problems << :seat1_no_license if plane && seat1 && seat1.person && !seat1.person.has_relevant_licenses_for(self)
    @problems.empty?
  end

  def all_versions
    (versions + Version.where(:abstract_flight_id => id)).sort_by { |e| e.created_at }
  end

  def all_changes
    all_versions.select { |version| version.event != "create" }
  end

  validates_presence_of :plane
  validates_presence_of :departure
  validates_presence_of :seat1_id
  validates_presence_of :controller
  validates_presence_of :from
  validates_presence_of :to

  accepts_string_for :plane, :parent_method => 'registration'
  accepts_string_for :from, :parent_method => ['registration', 'name']
  accepts_string_for :to, :parent_method => ['registration', 'name']

  def initialize(*args)
    super
    if new_record?
      self.duration ||= -1
    end
  end

  def launch_type_short
    I18n.t("flight.launch_types.#{ launch.nil? ? "self" : launch.class.to_s.underscore }.short")
  end

  def launch_type_long
    I18n.t("flight.launch_types.#{ launch.nil? ? "self" : launch.class.to_s.underscore }.long")
  end

  def cost
    unless @cost
      candidates = FlightCostRule.for(self).map { |cr| cr.apply_to(self) }
      candidates = candidates.sort_by { |a| a.free_sum }
      @cost = candidates.first
    end
    @cost
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
      elsif !plane.can_fly_without_engine || plane.default_engine_duration_to_duration
        duration
      else
        read_attribute(:engine_duration)
      end
    end
  end

  def departure_date=(d)
    unless d.nil?
      write_attribute(:departure_date, d.to_date)
    end
  end

  # Departure as DateTime
  def departure
    (departure_date + [0, departure_i].max.minutes).to_datetime
  end

  def departure=(time)
    self.departure_date = time.to_date if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include? time.class
    self.departure_time = time
  end

  # Arrival as DateTime
  def arrival
    if arrival_i >= 0 && departure_i >= 0
      if arrival_i > departure_i
        (departure_date + arrival_i.minutes).to_datetime
      else
        (departure_date + arrival_i.minutes + 1.day).to_datetime
      end
    end
  end

  def departure_time
    @departure_day_time ||= DayTime.new(departure_i)
    @departure_day_time.minutes = departure_i
    @departure_day_time
  end

  def departure_time=(time)
    set_time(:departure_i, time)
  end

  def arrival_time
    @arrival_day_time ||= DayTime.new(arrival_i)
    @arrival_day_time.minutes = arrival_i
    @arrival_day_time
  end

  def arrival_time=(time)
    set_time(:arrival_i, time)
  end
  alias_method "arrival=", "arrival_time="

  def duration
    if departure_i < 0 || arrival_i < 0 
      -1
    else
      (arrival_i - departure_i) % 1440
    end
  end

  def duration=(i)
    unless departure_i < 0
      self.arrival_i = (departure_i + i) % 1440
    end
  end

  def duration_time_span
    @duration_time_span ||= TimeSpan.new(duration)
    @duration_time_span.minutes = duration
    @duration_time_span
  end

  def landed?
    arrival_i > 0
  end

  def seat1
    crew_members.find_all { |m| [ UnknownCrewMember, PilotInCommand, Trainee ].include?(m.class) }.first
  end

  def seat2
    crew_members.find_all { |m| [ Instructor, PersonCrewMember, NCrewMember ].include?(m.class) }.first
  end

  def seat1_id
    seat1 && seat1.person? && seat1.person.id
  end

  def seat2_id
    seat2 && ((seat2.person? && seat2.person.id) || (seat2.n? && "+#{seat2.n}"))
  end

  def seat1_id=(id)
    self.seat1 = (id != '' ? id : nil)
  end

  def seat2_id=(id)
    self.seat2 = (id != '' ? id : nil)
  end

  def seat1=(obj)
    unless obj.nil?
      old = seat1
      unless obj == "unknown"
        obj = Person.find(obj) unless obj.is_a?(Person)
        if obj.trainee?(self)
          new = Trainee.new(:person => obj)
        else
          new = PilotInCommand.new(:person => obj)
        end
      else
        new = UnknownCrewMember.new
      end
      if !new.equals?(old)
        crew_members.delete old unless old.nil?
        crew_members << new
        new.save
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
      obj = $1.to_i if obj =~ /^\+([0-9]+)$/
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
        crew_members << new
        new.save
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
      obj.save
      self.launch = obj
      save
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
      Purpose.get('training')
    else
      Purpose.get('exercise')
    end
  end

  def history
    #TODO add manual cost?
    #[revisions, [PilotInCommandRevision, TraineeRevision, PersonCrewMemberRevision,
    #  NCrewMemberRevision, WireLaunchRevision, TowLaunchRevision].map { |c| c.find(:all, :conditions => { :abstract_flight_id => id }) }].flatten.sort_by { |r| r.revisable_current_at }
  end

  def aggregation_id
   #flight can be only aggregated if it is a local flight
   @aggregation_id ||= generate_aggregation_id
  end

  def generate_aggregation_id
    from == to && Digest::SHA256.hexdigest("#{plane_id.to_s}" + ((crew_members.sort_by { |c| c.class.to_s }).map {|m| m.person_id + m.class.name}).join + "#{departure_date}" + from_id.to_s)
  end
  def grouping_purposes
    [purpose]
  end

  def grouping_planes
    [plane]
  end

  def grouping_people
    crew_members.select { |m| [ UnknownCrewMember, PilotInCommand, Trainee, Instructor ].include?(m.class) }.map(&:person).reject(&:'nil?')
  end

  def grouping_licenses
    grouping_people.map { |p| p.relevant_licenses_for(self).first }.reject(&:'nil?')
  end

  def grouping_people_groups
    grouping_people.map(&:group).uniq.reject(&:'nil?')
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
    rel.order('departure_date DESC, departure_i DESC').limit(1).first.departure rescue DateTime.now
  end

  def self.oldest_departure(rel = AbstractFlight)
    rel.order('departure_date ASC, departure_i ASC').limit(1).first.departure rescue 2.years.ago
  end

=begin
  def to_j
    { :id => id,
      :plane =>
        { :id => plane_id,
          :registration => plane.registration },
      :seat1 => 
        { :person => 
          { :id => seat1.person.id,
            :name => seat1.person.name },
          :type => seat1.type,
          :pic => seat1.is_a?(PilotInCommand) || (seat1.is_a?(Trainee) && seat2.nil?) },
      :seat2 => 
        { :person => 
          { :id => seat2.person.id,
            :name => seat2.person.name },
          :type => seat2.type,
          :pic => !seat1.is_a?(PilotInCommand) && (!seat1.is_a?(Trainee) || !seat2.nil?) },
      :from => 
        { :id => from_id,
          :name => from.name,
          :re
    }
  end
=end

protected
  def rational_day_to_minutes(r)
    (r * 1440).to_i
  end

  def time_to_minutes(t)
    t.hour * 60 + t.min
  end

  def set_time(method, time)
    if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include? time.class
      time = time.to_datetime.utc
      send("#{method}=", time_to_minutes(time))
    elsif Integer === time
      send("#{method}=", time)
    elsif String === time
      send("#{method}=", DayTime.parse(time))
    else
      send("#{method}=", -1)
    end
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

  def execute_soft_validation
    self.problems_exist = !soft_validate
    true
  end

  def association_changed(obj)
    b = !soft_validate
    update_attribute :problems_exist, b if problems_exist != b
  end
end
