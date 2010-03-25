class Plane < ActiveRecord::Base
  include UuidHelper
  
  has_many :flights
  belongs_to :plane_cost_category
  
  #added methods may rely on associations
  include PlaneAddition
  
  def to_s
    registration || ""
  end
  
  def self.shared_attribute_names
    [ :id, :registration, :make, :competition_sign ]
  end
  
  def shared_attributes
    self.attributes.reject { |k, v| !self.class.shared_attribute_names.include?(k.to_sym) }
  end
end
