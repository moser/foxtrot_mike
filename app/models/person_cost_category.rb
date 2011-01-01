class PersonCostCategory < ActiveRecord::Base
  include Membership
  has_many :person_cost_category_memberships
  has_many :time_cost_rules
  has_many :tow_cost_rules
  has_many :wire_launch_cost_rules
  membership :person_cost_category_memberships

  validates_presence_of :name
end
