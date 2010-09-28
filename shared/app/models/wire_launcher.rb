class WireLauncher < ActiveRecord::Base
  include UuidHelper
  include Membership
  has_many :wire_launcher_cost_category_memberships
  membership :wire_launcher_cost_category_memberships
  
  include WireLauncherAddition

  validates_presence_of :registration
  
  def to_s
    registration
  end
  
  def self.shared_attribute_names
    [ :id, :registration ]
  end
end
