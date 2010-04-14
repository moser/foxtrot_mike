class WireLauncher < ActiveRecord::Base
  include UuidHelper
  has_many :wire_launcher_cost_category_memberships
  
  include WireLauncherAddition
  
  def to_s
    registration
  end
  
  def self.shared_attribute_names
    [ :id, :registration ]
  end
end
