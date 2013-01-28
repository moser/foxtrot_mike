class WireLauncherCostCategory < ActiveRecord::Base
  include Membership
  has_many :wire_launcher_cost_category_memberships
  has_many :wire_launch_cost_rules
  membership :wire_launcher_cost_category_memberships

  validates_presence_of :name

  default_scope order("name ASC")

  def matches?(flight)
    if flight.launch.is_a?(WireLaunch)
      wire_launcher_ids_at(flight.departure).include?(flight.launch.wire_launcher.id)
    else
      false
    end
  end

  def find_concerned_accounting_entry_owners(&blk)
    wire_launcher_cost_category_memberships.map { |m| m.find_concerned_accounting_entry_owners(&blk) }.flatten.uniq
  end
end
