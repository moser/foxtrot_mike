class AccountingEntry < ActiveRecord::Base
  belongs_to :from, :class_name => "FinancialAccount"
  belongs_to :to, :class_name => "FinancialAccount"
  belongs_to :accounting_session
  belongs_to :item, :polymorphic => true
  validates_presence_of :from, :to, :value
 
  def from_account_number
    from.try(:number)
  end

  def to_account_number
    to.try(:number)
  end

  def from_account_number=(n)
    self.from = FinancialAccount.where(number: n).first
  end

  def to_account_number=(n)
    self.to = FinancialAccount.where(number: n).first
  end

  def value_f
    value / 100.0
  end

  def value_f=(f)
    f = f.to_f if String === f
    self.value = (f * 100).round
  end

  def date
    if item
      item.departure_date
    else
      (accounting_session.try(:accounting_date) || created_at).to_date
    end
  end

  def text
    if item
      if AbstractFlight === item
        "#{item.class.l} (#{item.plane.registration})"
      else
        item.class.l
      end
    else
      read_attribute(:text)
    end
  end

  def category_text
    read_attribute(:text) || self.class.l(:flight_cost_text)
  end
end
