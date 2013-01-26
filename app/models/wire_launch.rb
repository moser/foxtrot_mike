class WireLaunch < ActiveRecord::Base
  def self.writable_attributes
    [ :operator_id, :wire_launcher_id ]
  end

  before_update :before_update_invalidate_accounting_entries
  after_destroy :delete_accouting_entries

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
    wire_launcher.financial_account_at(departure_date)
  end

  def departure_date
    abstract_flight.departure_date
  end

  def abstract_flight_changed
  end

  def to_s
    "wire_launch"
  end

  def as_json(options = {})
    super(options.merge(methods: [ :cost, :type, :editable ], except: [ :created_at, :updated_at, :accounting_entries_valid ]))
  end

  def type
    self.class.to_s
  end

  def editable
    abstract_flight.editable?
  end

  def concerned_people
    [ operator ]
  end

private
  def invalidation_necessary?
    changes.keys.include?("wire_launcher_id")
  end

  def before_update_invalidate_accounting_entries
    self.accounting_entries_valid = false if invalidation_necessary? && abstract_flight.editable?
    true
  end

  def delete_accouting_entries
    accounting_entries_without_validity_check.delete_all
  end
end
