class WireLaunchCostRule < ActiveRecord::Base
  include ValidityCheck
  include AccountingEntryInvalidation
  include Immutability

  after_save :after_save_invalidate_accounting_entries

  belongs_to :wire_launcher_cost_category
  belongs_to :person_cost_category
  immutable :person_cost_category, :wire_launcher_cost_category

  has_many :cost_rule_conditions, :as => :cost_rule, :after_add => :association_changed, :after_remove => :association_changed
  has_many :wire_launch_cost_items, :after_add => :association_changed, :after_remove => :association_changed

  validates_presence_of :wire_launcher_cost_category, :person_cost_category
  validates_with ValidFromValidator, :attributes => :valid_from

  def apply_to(flight)
    costs = wire_launch_cost_items.map { |i| i.apply_to(flight) }
    Cost.new(self, costs)
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

  def find_concerned_accounting_entry_owners(from = valid_from, to = valid_to)
    wire_launcher_cost_category.find_concerned_accounting_entry_owners { |r| r.between(min_date(valid_from, from), max_date(valid_to, to)) }
  end

  def association_changed(obj)
    invalidate_concerned_accounting_entries
  end

private
  def after_save_invalidate_accounting_entries
    created = changes.keys.include?("id")
    if created
      invalidate_concerned_accounting_entries
    else
      invalidate_concerned_accounting_entries(old_or_current(:valid_from), old_or_current(:valid_to))
    end
  end
end
