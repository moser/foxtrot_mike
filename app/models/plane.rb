class Plane < ActiveRecord::Base
  include UuidHelper  
  include Membership

  has_paper_trail

  belongs_to :financial_account 
  has_many :flights, :include => [:from, :to, :crew_members], :class_name => "AbstractFlight"
  has_many :plane_cost_category_memberships, :order => "valid_from ASC"  
  belongs_to :legal_plane_class
  belongs_to :group
  membership :plane_cost_category_memberships

  validates_presence_of :legal_plane_class, :group
  
  def to_s
    registration || ""
  end
  
  def self.shared_attribute_names
    [ :id, :registration, :make, :competition_sign, :group_id, :default_launch_method, :has_engine, 
      :can_fly_without_engine, :can_tow, :can_be_towed, :can_be_wire_launched, :disabled ]

  end
  
  def shared_attributes
    self.attributes.reject { |k, v| !self.class.shared_attribute_names.include?(k.to_sym) }
  end
  
  def engine_duration_possible?
    has_engine && can_fly_without_engine
  end

  def <=>(other)
    to_s <=> other.to_s
  end

  def info
    "#{make}, #{group.name}"
  end
end
