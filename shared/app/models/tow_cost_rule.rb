class TowCostRule < ActiveRecord::Base
  belongs_to :plane_cost_category
  belongs_to :person_cost_category
  has_many :tow_levels

  include ValidityCheck
end
