class TowCostRule < ActiveRecord::Base
  belongs_to :plane_cost_category
  belongs_to :person_cost_category
  validates_uniqueness_of :level, :scope => [:plane_cost_category_id, :person_cost_category_id]
end
