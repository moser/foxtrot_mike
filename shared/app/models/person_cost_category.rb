class PersonCostCategory < ActiveRecord::Base
  has_many :person_cost_category_memberships
  #has_and_belongs_to_many :people
  has_many :time_cost_rules
  has_many :tow_cost_rules
  has_many :wire_launch_cost_rules
end
