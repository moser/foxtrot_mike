class TowFlight < AbstractFlight
  before_validation :copy_from_abstract_flight
  before_update :before_update_invalidate_accounting_entries
  has_one :abstract_flight, :as => :launch, :readonly => false #the towed flight

  validates_presence_of :abstract_flight

  include LaunchAccountingEntries

  def editable?
    !!abstract_flight.try(:editable?)
  end


  def cost_hint
    abstract_flight.cost_hint rescue nil
  end

  def cost_responsible
    abstract_flight.cost_responsible rescue nil
  end

  def financial_account
    plane.financial_account_at(departure_date)
  end

  def purpose
    :tow
  end

  def initialize(*args)
    super(*args)
    copy_from_abstract_flight
  end

  def abstract_flight_changed
    copy_from_abstract_flight
    save if changed?
  end

  def to_s
    "tow_launch"
  end
  
  def is_tow
    true
  end

  def as_json(options = {})
    super(options).merge({ abstract_flight_id: abstract_flight.id })    
  end

private
  def copy_from_abstract_flight
    if abstract_flight
      self.departure_date = abstract_flight.departure_date
      self.departure_i = abstract_flight.departure_i
      self.from = abstract_flight.from
      self.controller = abstract_flight.controller
    end
  end

  def invalidation_necessary?
    !(changes.keys & ["plane_id", "departure_date", "departure_i", "arrival_i", "engine_duration", "cost_hint_id"]).empty?
  end

  def before_update_invalidate_accounting_entries
    self.accounting_entries_valid = false if invalidation_necessary? && abstract_flight.editable?
    true
  end
end
