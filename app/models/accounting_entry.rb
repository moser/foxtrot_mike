class AccountingEntry < ActiveRecord::Base
  belongs_to :from, :class_name => "FinancialAccount"
  belongs_to :to, :class_name => "FinancialAccount"
  belongs_to :accounting_session
  belongs_to :item, :polymorphic => true
  validates_presence_of :from, :to, :value
end
