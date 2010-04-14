class Plane < ActiveRecord::Base
  include UuidHelper
  
  has_many :flights
  has_many :plane_cost_category_memberships
  belongs_to :group
  
  #added methods may rely on associations
  include PlaneAddition
  
  def to_s
    registration || ""
  end
  
  def self.shared_attribute_names
    [ :id, :registration, :make, :competition_sign, :group_id ]
  end
  
  def shared_attributes
    self.attributes.reject { |k, v| !self.class.shared_attribute_names.include?(k.to_sym) }
  end
  
  def engine_duration?
    has_engine && can_fly_without_engine
  end
end
