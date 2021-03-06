class Flight < AbstractFlight
  belongs_to :cost_hint
  belongs_to :accounting_session

  before_save :check_editability
  before_update :before_update_invalidate_accounting_entries

  accepts_nested_attributes_for :liabilities

  validate do |f|
    errors.add(:base, I18n.t("activerecord.errors.messages.not_editable")) unless f.editable?
  end

  def create_accounting_entries
    accounting_entries_without_validity_check.destroy_all
    if cost && cost_responsible
      plane_account = plane.financial_account_at(departure_date)
      flight_sum = cost.free_sum
      liabilities_with_default.map do |l|
        value = (proportion_for(l) * flight_sum).round
        unless value == 0
          AccountingEntry.create(:from => l.person.financial_account_at(departure_date), :to => plane_account,
                                 :value => value, :item => self)
        end
      end
      cost.bound_items.map do |i|
        unless i.value == 0
          AccountingEntry.create(:from => i.financial_account, :to => plane_account,
                                 :value => i.value, :item => self)
        end
      end
      if launch
        launch.create_accounting_entries
      end
    end
    update_attribute :accounting_entries_valid, true
  end

  def invalidate_accounting_entries
    if editable? && !id.nil?
      update_attribute :accounting_entries_valid, false
      launch.invalidate_accounting_entries if launch
    end
  end

  def accounting_entries_with_validity_check
    unless accounting_entries_valid?
      create_accounting_entries
    end
    accounting_entries_without_validity_check(true) + (launch.nil? ? [] : launch.accounting_entries)
  end

  alias_method_chain :accounting_entries, :validity_check

  def liabilities_with_default
    unless seat1_role == :unknown
      liabilities.count == 0 ? [ DefaultLiability.new(self) ] : liabilities
    else
      liabilities
    end
  end


  def proportion_sum
    liabilities_with_default.map { |l| l.proportion }.sum
  end

  def value_for(liability)
    (proportion_for(liability) * free_cost_sum.to_f).round
  end

  def proportion_for(liability)
    liability.proportion.to_f / proportion_sum.to_f
  end

  def liabilities_attributes
    liabilities.map { |l| l.attributes }
  end

  def shared_attributes
    a = super
    a[:liabilities_attributes] = liabilities_attributes
    a
  end

  def initialize(*args)
    super(*args)
    if new_record?
      self.departure_date ||= Date.today
    end
  end

  def editable?
    accounting_session.nil? || !accounting_session.finished? 
  end

  def self.writable_attributes
    AbstractFlight.writable_attributes + [ :controller_id, :departure_date, :departure_i, :from_id, :cost_hint_id ] #TODO add launch
  end

  def as_json(options={})
    super(options).merge({ liabilities: liabilities, cost_responsible_id: cost_responsible.try(:id) })
  end

private
  def check_editability
    #raise "not editable" unless editable?
    editable?
  end

  def invalidation_necessary?
    !(changes.keys & ["plane_id", "launch_id", "launch_type", "departure_date", "departure_i", "arrival_i", "engine_duration", "cost_hint_id", "seat1_person_id"]).empty?
  end

  def before_update_invalidate_accounting_entries
    if invalidation_necessary? && editable?
      self.accounting_entries_valid = false
      launch.accounting_entries_valid = false if launch
    end
    true
  end

  def association_changed(obj)
    super(obj)
    invalidate_accounting_entries
  end
end
