class AccountingEntry < ActiveRecord::Base
  belongs_to :from, :class_name => "FinancialAccount"
  belongs_to :to, :class_name => "FinancialAccount"
  belongs_to :accounting_session
  belongs_to :item, :polymorphic => true
  validates_presence_of :from, :to, :value

  def date
    if item
      item.departure_date
    else
      accounting_session.try(:end_date) || created_at
    end
  end

  def text
    if item
      item.class.l
    else
      read_attribute(:text)
    end
  end
end
