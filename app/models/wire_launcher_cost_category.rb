class WireLauncherCostCategory < ActiveRecord::Base
  include Membership
  has_many :wire_launcher_cost_category_memberships
  has_many :wire_launch_cost_rules
  membership :wire_launcher_cost_category_memberships

  validates_presence_of :name

  def matches?(flight)
    if flight.launch.is_a?(WireLaunch)
      wire_launchers_at(flight.departure).include?(flight.launch.wire_launcher)
    else
      false
    end
  end
end
