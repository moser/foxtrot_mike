class Airfield < ActiveRecord::Base
  include UuidHelper
  include AirfieldAddition

  has_many :flights_from, :foreign_key => 'from_id', :class_name => 'Flight'
  has_many :flights_to, :foreign_key => 'to_id', :class_name => 'Flight'
  
  def to_s
    #registration || name || ''
    if name && registration
      "#{name} (#{registration})"
    elsif registration
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
end
