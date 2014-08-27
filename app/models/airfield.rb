class Airfield < ActiveRecord::Base
  include UuidHelper

  has_many :flights_from, :foreign_key => 'from_id', :class_name => 'AbstractFlight', :include => AbstractFlight::IncludeAll
  has_many :flights_to, :foreign_key => 'to_id', :class_name => 'AbstractFlight', :include =>  AbstractFlight::IncludeAll

  belongs_to :duplicate_of, class_name: 'Airfield'
  has_many :duplications, class_name: 'Airfield', foreign_key: 'duplicate_of_id'

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

  def controller_log(date)
    @controller_log ||= ControllerLog.new(self, date)
  end

  def merge_to(other_airfield)
    flights_from.each do |f|
      f.update_attribute :from, other_airfield
    end
    flights_to.each do |f|
      f.update_attribute :to, other_airfield
    end
    update_attributes disabled: true, deleted: true, duplicate_of_id: other_airfield.id
  end
end
