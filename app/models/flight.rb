class Flight < AbstractFlight   
  has_many :liabilities
  belongs_to :cost_hint
  belongs_to :accounting_session

  before_save :check_editability

  validate do |f|
    errors.add(:base, I18n.t("activerecord.errors.not_editable")) unless f.editable?
  end
  
  def create_accounting_entries
    accounting_entries_without_validity_check.delete_all
    if cost
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
  
  def invalidate_accounting_entries
    update_attribute :accounting_entries_valid, false
    delay.create_accounting_entries
    launch.invalidate_accounting_entries if launch
  end
  
  def accounting_entries_with_validity_check
    unless accounting_entries_valid?
      create_accounting_entries
    end
    accounting_entries_without_validity_check(true) + (launch.nil? ? [] : launch.accounting_entries)
  end
  
  alias_method_chain :accounting_entries, :validity_check

  def liabilities_with_default
    liabilities.count == 0 ? [ DefaultLiability.new(self) ] : liabilities
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
      self.departure ||= Date.today
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
end
