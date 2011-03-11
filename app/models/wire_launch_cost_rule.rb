class WireLaunchCostRule < ActiveRecord::Base
  belongs_to :wire_launcher_cost_category
  belongs_to :person_cost_category

  has_many :cost_rule_conditions, :as => :cost_rule
  has_many :wire_launch_cost_items
  include ValidityCheck
  
  validates_presence_of :wire_launcher_cost_category, :person_cost_category

  def apply_to(flight)
    costs = wire_launch_cost_items.map { |i| i.apply_to(flight) }
    Cost.new(self, costs)
#    aggregate = Hash.new { |h,k| h[k] = [] }
#    costs.each do |c|
#      aggregate[c.financial_account] << c.value
#    end
#    Cost.new(self, aggregate.map { |k,v| CostItem.new(v.sum, k) })
  end

  def matches?(flight, conditions = nil)
    if flight.launch && flight.launch.is_a?(WireLaunch)
      unless conditions
        valid_at?(flight.departure) && matches?(flight, [ person_cost_category, wire_launcher_cost_category, cost_rule_conditions ].flatten)
      else
        conditions.empty? || (conditions[0].matches?(flight) && matches?(flight, conditions[1..-1]))
      end
    end
  end

  def self.for(flight)
    unless flight.launch.nil? || !flight.launch.is_a?(WireLaunch) || flight.cost_responsible.nil?
      all.find_all { |cr| cr.matches?(flight) }
    else
      []
    end
  end
  
  def find_concerned_accounting_entry_owners
    wire_launcher_cost_category.find_concerned_accounting_entry_owners { |r| r.between(valid_from, valid_to) }
  end
end
