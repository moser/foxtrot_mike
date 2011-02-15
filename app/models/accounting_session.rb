class AccountingSession < ActiveRecord::Base
  has_many :accounting_entries
  has_many :flights
  validates_presence_of :name
#  validate do |f|
#    errors.add(:end_date, I18n.t("activerecord.errors.greater_than", :count => AccountingSession.latest_session_end)) unless f.end_date > AccountingSession.latest_session_end
#  end

  def initialize(*args)
    super(*args)
    if new_record? && end_date.nil?
      self.end_date = start_date.end_of_month
    end
    
  end

  def end_date=(d)
    d = d.to_date
    write_attribute(:end_date, d)
  end

  def finished?
    !finished_at.nil?
  end
  
  def previous
    AccountingSession.where("end_date < ?", self.end_date).order("end_date DESC").limit(1).first
  end
  
  def start_date
    (previous && previous.end_date || AccountingSession.latest_session_end) + 1.day
  end

  def self.booking_now
    DateTime.now
  end
  
  # The end date of the latest accounting session.
  # If there are no accounting sessions, the day before the first flight.
  # If there are no flights, it is yesterday.
  # This date is used to determine if any cost related models
  # may be changed. (E.g. a cost rule that was valid at this date must
  # not be changed.)
  def self.latest_session_end
    AccountingSession.select(:end_date).maximum(:end_date) || (AbstractFlight.oldest_departure - 1.day).to_date
  end
end
