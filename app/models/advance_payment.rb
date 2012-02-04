class AdvancePayment < ActiveRecord::Base
  belongs_to :financial_account
  belongs_to :from, :class_name => "FinancialAccount"

  default_scope order("date DESC")

  def value_f
    value.to_f / 100.0
  end

  def value_f=(f)
    self.value = (f.to_f * 100).to_i
  end

  def item
    false
  end
end
