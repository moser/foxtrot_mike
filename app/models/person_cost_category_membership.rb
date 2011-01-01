class PersonCostCategoryMembership < ActiveRecord::Base
  belongs_to :person_cost_category
  belongs_to :person
  include ValidityCheck

  validates_presence_of :person, :person_cost_category
end
