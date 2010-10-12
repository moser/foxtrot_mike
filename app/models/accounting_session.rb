class AccountingSession < ActiveRecord::Base
  has_many :accounting_entries
  validates_presence_of :name
end
