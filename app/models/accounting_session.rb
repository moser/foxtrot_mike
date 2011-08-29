class AccountingSession < ActiveRecord::Base
  has_many :accounting_entries
  has_many :flights, :order => "departure_date ASC, departure_date ASC"
  validates_presence_of :name, :start_date, :end_date
  validate do |a|
    errors.add(:end_date, AccountingSession.l(:must_not_be_in_the_future)) if a.end_date && a.end_date > DateTime.now.to_date
  end
  
  #TODO make all other flights methods unaccessible
  def flights_with_default
    if finished?
      flights_without_default
    else
      Flight.include_all.where(AbstractFlight.arel_table[:departure_date].gteq(start_date)).
                            where(AbstractFlight.arel_table[:departure_date].lteq(end_date)).
                            where(:accounting_session_id => nil).
                            order('departure_date ASC').all
    end
  end
  
  alias_method_chain :flights, :default

  def initialize(*args)
    super(*args)
    if new_record? && start_date.nil? && end_date.nil?
      self.start_date = AccountingSession.latest_session_end + 1.day
      self.end_date = start_date.end_of_month
    end
    
  end
  
  def start_date=(d)
    d = d.to_date if d.respond_to?(:to_date)
    write_attribute(:start_date, d)
  end

  def end_date=(d)
    d = d.to_date if d.respond_to?(:to_date)
    write_attribute(:end_date, d)
  end

  def finished?
    !finished_at.nil?
  end
  alias :finished :finished?
  
  def finished=(b)
    unless !b || finished?
      flights.each do |f|
        f.update_attribute :accounting_session, self
      end
      update_attribute :finished_at, DateTime.now
    end
  end

#  def self.booking_now
#    DateTime.now
#  end
  
  # The end date of the latest accounting session.
  # If there are no accounting sessions, the day before the first flight.
  # If there are no flights, it is yesterday.
  # This date is used to determine if any cost related models
  # may be changed. (E.g. a cost rule that was valid at this date must
  # not be changed.)
  def self.latest_finished_session_end
    AccountingSession.where(AccountingSession.arel_table[:finished_at].not_eq(nil)).select(:end_date).maximum(:end_date) || (AbstractFlight.oldest_departure - 1.year).to_date
  end

  def self.latest_session_end
    AccountingSession.select(:end_date).maximum(:end_date) || (AbstractFlight.oldest_departure - 1.day).to_date
  end
end
