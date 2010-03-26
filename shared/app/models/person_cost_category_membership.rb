class PersonCostCategoryMembership < ActiveRecord::Base
  belongs_to :person_cost_category
  belongs_to :person
  include ValidityCheck
end
