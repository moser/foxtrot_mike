class AccountingSession < ActiveRecord::Base
  has_many :accounting_entries
  has_many :flights
  validates_presence_of :name

  def finished?
    !finished_at.nil?
  end

  def self.booking_now
    DateTime.now
  end
end
