class FlightCostRule < ActiveRecord::Base
  belongs_to :person_cost_category
  belongs_to :plane_cost_category

  has_many :cost_rule_conditions, :as => :cost_rule
  has_many :flight_cost_items

  include ValidityCheck

  validates_presence_of :person_cost_category, :plane_cost_category

  def apply_to(flight)
    costs = flight_cost_items.map { |i| i.apply_to(flight) }
    Cost.new(self, costs)
#    aggregate = Hash.new { |h,k| h[k] = [] }
#    costs.each do |c|
#      aggregate[c.financial_account] << c.value
#    end
#    Cost.new(self, aggregate.map { |k,v| CostItem.new(v.sum, k) })
  end

  def matches?(flight, conditions = nil)
    unless conditions
      valid_at?(flight.departure) && flight_type == flight.class.to_s && matches?(flight, [ person_cost_category, plane_cost_category, cost_rule_conditions ].flatten)
    else
      conditions.empty? || (conditions[0].matches?(flight) && matches?(flight, conditions[1..-1]))
    end
  end

  def self.for(flight)
    unless flight.plane.nil? || flight.cost_responsible.nil? || flight.duration < 0
      all.find_all { |cr| cr.matches?(flight) }
    else
      []
    end
  end
end
