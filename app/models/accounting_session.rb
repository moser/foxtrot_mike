class AccountingSession < ActiveRecord::Base
  has_many :accounting_entries
  validates_presence_of :name

  def self.booking_now
    DateTime.now
  end
end
