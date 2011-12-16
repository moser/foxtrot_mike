class TowFlight < AbstractFlight
  before_validation :copy_from_abstract_flight
  before_update :before_update_invalidate_accounting_entries
  after_update :after_update_invalidate_accounting_entries
  has_one :abstract_flight, :as => :launch, :readonly => false #the towed flight

  include LaunchAccountingEntries


  def cost_hint
    abstract_flight.cost_hint rescue nil
  end

  def cost_responsible
    abstract_flight.cost_responsible rescue nil
  end

  def financial_account
    plane.financial_account
  end

  def purpose
    @purpose ||= Purpose.get('tow')
  end

  def initialize(*args)
    super(*args)
    if new_record?
      self.duration ||= 0
    end
  end

  def abstract_flight_changed
    copy_from_abstract_flight
    save if changed?
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

  def after_update_invalidate_accounting_entries
    delay.create_accounting_entries if invalidation_necessary? && abstract_flight.editable? && !Rails.env.test? #HACK...
    # delay = false in test env sucks here, because when this is executed immediatly we get an infinite loop here.
    # this should work in test and other envs.
  end
end
