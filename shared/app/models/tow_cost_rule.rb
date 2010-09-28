class TowCostRule < ActiveRecord::Base
  belongs_to :plane_cost_category
  belongs_to :person_cost_category
  has_many :tow_levels

  include ValidityCheck

  validates_presence_of :plane_cost_category, :person_cost_category
end
