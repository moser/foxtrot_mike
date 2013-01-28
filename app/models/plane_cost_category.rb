class PlaneCostCategory < ActiveRecord::Base
  include Membership
  has_many :plane_cost_category_memberships
  has_many :flight_cost_rules
  membership :plane_cost_category_memberships

  validates_presence_of :name

  default_scope order("name ASC")

  def matches?(flight)
    unless flight.plane.nil?
      plane_ids_at(flight.departure).include?(flight.plane.id)
    else
      false
    end
  end

  def find_concerned_accounting_entry_owners(&blk)
    plane_cost_category_memberships.map { |m| m.find_concerned_accounting_entry_owners(&blk) }.flatten.uniq
  end
end
