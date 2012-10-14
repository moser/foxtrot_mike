class Airfield < ActiveRecord::Base
  include UuidHelper

  has_paper_trail

  has_many :flights_from, :foreign_key => 'from_id', :class_name => 'AbstractFlight', :include => AbstractFlight::IncludeAll
  has_many :flights_to, :foreign_key => 'to_id', :class_name => 'AbstractFlight', :include =>  AbstractFlight::IncludeAll

  validates_presence_of :name
  validates_uniqueness_of :registration, :if => Proc.new { |airfield| airfield.registration != "" }

  default_scope order("name asc")
  scope :home, where(:home => true)

  def registration
    read_attribute(:registration) || ""
  end

  def to_s
    if registration && registration != ""
      registration
    else
      name
    end
  end

  def flights
    AbstractFlight.include_all.where(AbstractFlight.arel_table[:from_id].eq(id).or(AbstractFlight.arel_table[:to_id].eq(id)))
  end

  def srss
    @srss ||= SRSS.new(lat, long)
  end

  # returns if sunrise/sunset calculation makes sense
  def srss?
    lat != 0.0 && long != 0.0 #there should not be an airfield, somewhere in the ocean
  end

  def as_json(options)
    { :id => id, :name => name, :registration => registration, :disabled => disabled }
  end

  def controller_log(date)
    @controller_log ||= ControllerLog.new(self, date)
  end
end
