class FlightCostRule < ActiveRecord::Base
  include ValidityCheck
  include Immutability
  include AccountingEntryInvalidation

  after_save :after_save_invalidate_accounting_entries

  belongs_to :person_cost_category
  belongs_to :plane_cost_category
  immutable :person_cost_category, :plane_cost_category

  has_many :cost_rule_conditions, :as => :cost_rule, :after_add => :association_changed, :after_remove => :association_changed
  has_many :flight_cost_items, :after_add => :association_changed, :after_remove => :association_changed

  validates_presence_of :person_cost_category, :plane_cost_category
  validates_with ValidFromValidator, :attributes => :valid_from

  def apply_to(flight)
    costs = flight_cost_items.map { |i| i.apply_to(flight) }
    Cost.new(self, costs)
  end

  def matches?(flight, conditions = nil)
    unless conditions
      valid_at?(flight.departure_date) && flight_type == flight.class.to_s && matches?(flight, [ person_cost_category, plane_cost_category, cost_rule_conditions ].flatten)
    else
      conditions.empty? || (conditions[0].matches?(flight) && matches?(flight, conditions[1..-1]))
    end
  end

  def find_concerned_accounting_entry_owners(from = valid_from, to = valid_to)
    plane_cost_category.find_concerned_accounting_entry_owners { |r| r.between(min_date(valid_from, from), max_date(valid_to, to)) }
  end

  def self.for(flight)
    unless flight.plane.nil? || flight.cost_responsible.nil? || flight.duration < 0
      all.find_all { |cr| cr.matches?(flight) }
    else
      []
    end
  end

  def association_changed(obj)
    delay.invalidate_concerned_accounting_entries
  end

private
  def after_save_invalidate_accounting_entries
    created = changes.keys.include?("id")
    if created
      delay.invalidate_concerned_accounting_entries
    else
      delay.invalidate_concerned_accounting_entries(old_or_current(:valid_from), old_or_current(:valid_to))
    end
  end
end
