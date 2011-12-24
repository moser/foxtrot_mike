class Flight < AbstractFlight   
  has_many :liabilities, :after_add => :association_changed, :after_remove => :association_changed
  belongs_to :cost_hint
  belongs_to :accounting_session

  before_save :check_editability
  before_update :before_update_invalidate_accounting_entries
  after_update :after_update_invalidate_accounting_entries

  validate do |f|
    errors.add(:base, I18n.t("activerecord.errors.messages.not_editable")) unless f.editable?
  end

  def create_accounting_entries
    accounting_entries_without_validity_check.delete_all
    if cost && cost_responsible
      plane_account = plane.financial_account
      flight_sum = cost.free_sum
      liabilities_with_default.map do |l|
          AccountingEntry.create(:from => l.person.financial_account, :to => plane_account, 
                                   :value => (proportion_for(l) * flight_sum).round, :item => self)
      end
      cost.bound_items.map { |i| AccountingEntry.create(:from => i.financial_account, :to => plane_account,
                                                          :value => i.value, :item => self) }
    end
    update_attribute :accounting_entries_valid, true
  end

  def invalidate_accounting_entries(delayed = true)
    if editable? && !id.nil?
      update_attribute :accounting_entries_valid, false
      (delayed ? delay : self).create_accounting_entries
      launch.invalidate_accounting_entries(delayed) if launch
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
    unless seat1.is_a? UnknownCrewMember
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

  def liabilities_attributes=(attrs)
    unless attrs.nil?
      attrs.each do |h|
        obj = h.delete(:type).constantize.new(h)
        obj.id = h[:id]
        obj.save
        liabilities << obj
      end
    end
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

private
  def check_editability
    #raise "not editable" unless editable?
    editable?
  end

  def invalidation_necessary?
    !(changes.keys & ["plane_id", "launch_id", "launch_type", "departure_date", "departure_i", "arrival_i", "engine_duration", "cost_hint_id"]).empty?
  end

  def before_update_invalidate_accounting_entries
    self.accounting_entries_valid = false if invalidation_necessary? && editable?
    true
  end

  def after_update_invalidate_accounting_entries
    delay.create_accounting_entries if invalidation_necessary? && editable? && !Rails.env.test? #HACK...
    # delay = false in test env sucks here, because when this is executed immediatly we get an infinite loop here.
    # this should work in test and other envs.
  end

  def association_changed(obj)
    super(obj)
    delay.invalidate_accounting_entries
  end
end
