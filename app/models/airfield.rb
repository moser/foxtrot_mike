class Airfield < ActiveRecord::Base
  include UuidHelper

  has_paper_trail

  has_many :flights_from, :foreign_key => 'from_id', :class_name => 'Flight', :include => [:plane, :from, :to, :crew_members]
  has_many :flights_to, :foreign_key => 'to_id', :class_name => 'Flight', :include => [:plane, :from, :to, :crew_members]
  
  validates_presence_of :name
  validates_uniqueness_of :registration, :if => Proc.new { |airfield| airfield.registration != "" }
  
  def to_s
    if registration && registration != ""
      registration
    else
      name
    end
  end
  
  def self.shared_attribute_names
    [ :id, :registration, :name ]
  end
  
  def shared_attributes
    self.attributes.reject { |k, v| !self.class.shared_attribute_names.include?(k.to_sym) }
  end

  def flights
    Flight.include_all.where(Flight.arel_table[:from_id].eq(id).or(Flight.arel_table[:to_id].eq(id)))
  end
end
