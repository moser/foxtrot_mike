require "digest/sha2"

class AbstractFlight < ActiveRecord::Base
  Purposes = ['training', 'exercise', 'tow']
  IncludeAll = [:liabilities]
  before_save :replace_duplicates
  before_save :destroy_launch
  before_save :execute_soft_validation
  after_save :notify_launch
  after_destroy :delete_accouting_entries

  belongs_to :plane
  belongs_to :seat1_person, :class_name => "Person"
  belongs_to :seat2_person, :class_name => "Person"
  belongs_to :from, :class_name => "Airfield"
  belongs_to :to, :class_name => "Airfield"
  belongs_to :controller, :class_name => "Person"
  #launch == nil <=> selflaunched
  belongs_to :launch, :polymorphic => true, :readonly => false, :dependent => :destroy
  has_one :manual_cost, :as => :item
  has_many :accounting_entries, :as => :item
  has_many :liabilities, :after_add => :association_changed, :after_remove => :association_changed, :foreign_key => "flight_id"

  default_scope -> { order("departure_date DESC, departure_i DESC, type DESC").includes(IncludeAll) }
  scope :reverse_order, -> { reorder("departure_date ASC, departure_i ASC, type DESC").includes(IncludeAll) }

  serialize :problems, Hash
  serialize :cached_cost, Cost

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

    def on(date)
      where(departure_date: date)
    end
  end

  def self.writable_attributes
    [ :plane_id, :seat1_person_id, :seat2_person_id, :seat2_n, 
      :to_id, :arrival_i, :engine_duration, :comment, :launch_attributes, :liabilities_attributes ]
  end

  #accepts_nested_attributes_for :launch

  def seats_used
    (seat1_person ? 1 : 0 ) +
      (seat2_person ? 1: seat2_n)
  end

  def too_many_people_for_plane?
    plane && plane.seat_count < seats_used
  end

  def seat2_not_an_instructor?
    seat1_role == :trainee && (seat2_role != :instructor && seat2_role != :empty)
  end

  def launch_method_impossible?
    plane && ((self_launch? && !plane.selflaunching?) ||
              (tow_launch? && !plane.can_be_towed?) ||
              (wire_launch? && !plane.can_be_wire_launched?))
  end

  def self_launch?
    launch.nil?
  end

  def tow_launch?
    launch.is_a?(TowFlight)
  end

  def wire_launch?
    launch.is_a?(WireLaunch)
  end

  def seat1_no_license?
    plane && seat1_person && !seat1_person.has_relevant_licenses_for(self)
  end

  def no_cost_calculation_possible?
    plane && plane.warn_when_no_cost_rules && (cost_responsible.nil? || FlightCostRule.for(self).empty?)
  end

  def not_between_sr_and_ss?
    departure_date && ((departure_i >= 0 && from && from.srss? && (sr = from.srss.sunrise_i(departure_date)) > departure_i) ||
                       (arrival_i >= 0 && to && to.srss? && (ss = to.srss.sunset_i(departure_date)) < arrival_i))
  end

  def soft_validate
    self.problems = {}
    problems[:too_many_people] = {} if too_many_people_for_plane?
    problems[:seat2_is_not_an_instructor] = {} if seat2_not_an_instructor?
    problems[:launch_method_impossible] = {} if launch_method_impossible?
    problems[:seat1_no_license] = {} if seat1_no_license?
    problems[:no_cost_calculation_possible] = {} if no_cost_calculation_possible?
    if not_between_sr_and_ss?
      sr = (from && from.srss? && from.srss.sunrise_i(departure_date)) ||-1
      ss = (to && to.srss? && to.srss.sunset_i(departure_date)) ||-1
      problems[:not_between_sr_and_ss] = { :sr => DayTime.format(sr), :ss => DayTime.format(ss) }
    end
    [ :departure_i, :arrival_i ].each do |field|
      problems["#{field}_needed"] = {} if send(field) < 0
    end
    problems.empty?
  end

  validates_presence_of :plane
  validates_presence_of :departure_date
  validates_presence_of :seat1_person
  validates_presence_of :from
  validates_presence_of :to

  accepts_string_for :plane, :parent_method => 'registration'
  accepts_string_for :from, :parent_method => ['registration', 'name']
  accepts_string_for :to, :parent_method => ['registration', 'name']

  def initialize(*args)
    super(*args)
    if new_record?
      self.departure_date ||= Date.today
      self.duration ||= -1
    end
  end

  def launch_kind
    launch.nil? ? "self_launch" : launch.to_s
  end

  def calculate_cost
    candidates = FlightCostRule.for(self).map { |cr| cr.apply_to(self) }
    candidates = candidates.sort_by { |a| a.free_sum }
    self.cached_cost = candidates.first || Cost.new
  end

  def calculate_cost_if_necessary
    if !cached_cost || cached_cost.empty? || !accounting_entries_valid
      calculate_cost
    end
  end

  def cost
    cached_cost
  end

  def launch_cost
    unless launch.nil?
      launch.cost
    end
  end

  def cost_sum
    [ cost, (launch_cost || Cost.new) ].map { |c| c.sum }.sum
  end

  def free_cost_sum
    [ cost, (launch_cost || Cost.new) ].map { |c| c.free_sum }.sum
  end

  def cost_responsible
    seat1_person
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

  def seat1_role
    if seat1_person.nil?
      :unknown #like in "we do not know neither care who flew this plane"
    elsif seat1_person.trainee?(self)
      :trainee
    else
      :pic
    end
  end

  def seat2_role
    if seat2_person.nil? && seat2_n == 0
      :empty
    elsif seat2_n > 0
      :multiple_passengers
    elsif seat1_role == :trainee && seat2_person.instructor?(self)
      :instructor
    else
      :passenger
    end
  end

  def launch_attributes=(attrs)
    unless attrs.nil?
        unless attrs == "none"
        klass = attrs.delete(:type).constantize
        if attrs[:id]
          obj = klass.find(attrs[:id])
          obj.update_attributes(attrs.select { |k,_| klass.writable_attributes.include?(k.to_sym) })
        else
          obj = klass.new(attrs.select { |k,_| klass.writable_attributes.include?(k.to_sym) })
          obj.abstract_flight = self
          obj.save
          self.launch = obj
          save
        end
      else
        self.launch = nil
        save
      end
    end
  end

  def as_json(options = {})
    #soft_validate if problems_exist
    super(options.merge(methods: [ :editable, :purpose, :is_tow, :type, :editable?, :aggregation_id ], except: [ :created_at, :updated_at, :accounting_entries_valid, :accounting_session_id, :launch_id, :launch_type, :cost ])).merge({ launch: launch.as_json, cost: cost.as_json })
  end
  
  def is_tow
    false
  end

  def purpose
    if seat1_role == :trainee
      :training
    else
      :exercise
    end
  end

  def aggregation_id
   #flight can be only aggregated if it is a local flight
   @aggregation_id ||= generate_aggregation_id
  end

  def generate_aggregation_id
    from == to && 
      Digest::SHA256.hexdigest("#{plane_id.to_s}#{seat1_person_id}#{departure_date}#{from_id}")
  end

  def grouping_purposes
    [purpose]
  end

  def grouping_planes
    [plane]
  end

  def grouping_people
    [ seat1_person, seat2_person ].compact
  end

  def grouping_licenses
    grouping_people.map { |p| p.relevant_licenses_for(self).first }.reject(&:'nil?')
  end

  def grouping_people_groups
    grouping_people.map(&:group).compact.uniq
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
    includes(IncludeAll)
  end

  def self.latest_departure(rel = AbstractFlight)
    rel.order('departure_date DESC, departure_i DESC').limit(1).first.departure rescue DateTime.now
  end

  def self.oldest_departure(rel = AbstractFlight)
    rel.order('departure_date ASC, departure_i ASC').limit(1).first.departure rescue 2.years.ago
  end

  def editable?
    true
  end

  def editable
    editable?
  end

  def concerned_people
    [ seat1_person, seat2_person, controller, launch ? launch.concerned_people : [] ].flatten.uniq.compact
  end

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
  def replace_duplicates
    %w(plane seat1_person seat2_person from to controller).each do |attr|
      value = self.send(attr.to_sym)
      if value && value.duplicate_of
        self.send("#{attr}=".to_sym, value.duplicate_of)
      end
    end
  end

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

  def execute_cost_calculation
    calculate_cost
    true
  end

  def delete_accouting_entries
    accounting_entries_without_validity_check.destroy_all
  end

  def association_changed(obj)
    b = !soft_validate
    update_attribute :problems_exist, b if problems_exist != b
  end

  def notify_launch
    launch.abstract_flight_changed if launch
  end
end
