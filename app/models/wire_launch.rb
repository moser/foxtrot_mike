class WireLaunch < ActiveRecord::Base
  include UuidHelper
  
  before_update :before_update_invalidate_accounting_entries
  after_update :after_update_invalidate_accounting_entries

  has_paper_trail :meta => { :abstract_flight_id => Proc.new { |l| l.abstract_flight.id unless l.nil? || l.new_record? || l.abstract_flight.nil? } }

  has_many :accounting_entries, :as => :item
  belongs_to :wire_launcher
  belongs_to :operator, :class_name => "Person"
  has_one :abstract_flight, :as => :launch
  has_one :manual_cost, :as => :item

  validates_presence_of :wire_launcher

  include LaunchAccountingEntries

  class << self
    def between(from, to)
      if from && to
        joins(:abstract_flight).where("abstract_flights.departure_date >= ? AND abstract_flights.departure_date <= ?", from, to).select("wire_launches.*")
      elsif from
        after(from)
      elsif to
        before(to)
      else
        self.where("1 = 1")
      end
    end

    def after(from)
      joins(:abstract_flight).where("abstract_flights.departure_date >= ?", from).select("wire_launches.*")
    end

    def before(to)
      joins(:abstract_flight).where("abstract_flights.departure_date <= ?", to).select("wire_launches.*")
    end
  end

  def cost
    unless @cost
      candidates = WireLaunchCostRule.for(self.abstract_flight).map { |cr| cr.apply_to(self) }
      candidates = candidates.sort_by { |a| a.free_sum }
      @cost = candidates.first
    end
    @cost
  end

  def free_cost_sum
    cost.free_sum
  end

  def shared_attributes
    attributes
  end

  def self.short
    "W"
  end

  def financial_account
    wire_launcher.financial_account
  end

  def abstract_flight_changed
  end

private
  def invalidation_necessary?
    changes.keys.include?("wire_launcher_id")
  end

  def before_update_invalidate_accounting_entries
    self.accounting_entries_valid = false if invalidation_necessary? && abstract_flight.editable?
    true
  end

  def after_update_invalidate_accounting_entries
    delay.create_accounting_entries if invalidation_necessary? && abstract_flight.editable? && !Rails.env.test? #HACK...
    # delay = false in test env sucks here, because when this is executed immediatly we get an infinite loop here.
    # this should work in test and other envs.
  end
end
