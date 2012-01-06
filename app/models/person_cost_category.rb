class PersonCostCategory < ActiveRecord::Base
  include Membership
  has_many :person_cost_category_memberships
  has_many :flight_cost_rules
  has_many :wire_launch_cost_rules
  membership :person_cost_category_memberships

  validates_presence_of :name

  default_scope order("name ASC")

  def matches?(flight)
    unless flight.cost_responsible.nil?
      people_at(flight.departure).include?(flight.cost_responsible)
    else
      false
    end
  end
end
