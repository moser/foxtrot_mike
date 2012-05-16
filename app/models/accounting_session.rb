class AccountingSession < ActiveRecord::Base
  has_many :accounting_entries
  has_many :flights, :order => "departure_date ASC, departure_date ASC"

  belongs_to :credit_financial_account, :class_name => "FinancialAccount"

  validates_presence_of :name, :voucher_number, :accounting_date
  validates_presence_of :start_date, :end_date, :if => lambda { |s| !s.without_flights? }
  validate do |a|
    errors.add(:end_date, AccountingSession.l(:must_not_be_in_the_future)) if !a.without_flights? && a.end_date && a.end_date > DateTime.now.to_date
  end

  before_save :remove_dates_if_without_flights

  attr_reader :problems
  def soft_validate
    @problems = {}
    unless without_flights?
      unaccounted_flights = AbstractFlight.where(AbstractFlight.arel_table[:departure_date].lt(start_date)).where(:accounting_session_id => nil)
      count = unaccounted_flights.count
      oldest = unaccounted_flights.order("departure_date ASC").first
      if count > 0
        @problems[:unaccounted_flights_before_start] = { :count => count, :oldest => I18n.l(oldest.departure_date) }
      end
    end
    @problems[:financial_account_missing_number] = {} if concerned_financial_accounts.find { |a| !a.number? }
    @problems.empty?
  end

  def manual_accounting_entries
    accounting_entries_without_default.where(:manual => true)
  end

  #TODO make all other flights methods unaccessible
  def flights_with_default
    unless without_flights?
      if finished?
        flights_without_default
      else
        Flight.include_all.where(AbstractFlight.arel_table[:departure_date].gteq(start_date)).
                              where(AbstractFlight.arel_table[:departure_date].lteq(end_date)).
                              where(:accounting_session_id => nil).
                              order('departure_date ASC').all
      end
    else
      []
    end
  end
  alias_method_chain :flights, :default

  def accounting_entries_with_default
    if finished?
      accounting_entries_without_default
    else
      unless bank_debit?
        flights.map { |f| f.accounting_entries }.flatten + manual_accounting_entries
      else
        negative_financial_accounts.map { |f| AccountingEntry.new(:from => credit_financial_account, :to => f, :value => -f.balance, :accounting_session => self, :text => name) }
      end
    end
  end
  alias_method_chain :accounting_entries, :default

  def negative_financial_accounts 
    FinancialAccount.where("bank_account_number != ''").where(:advance_payment => false, :member_account => true).select { |f| f.balance < 0 }
  end

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
        f.accounting_entries.each do |e|
          e.update_attribute :accounting_session, self
        end
      end
      if bank_debit?
        accounting_entries.each { |e| e.save }
      end
      update_attribute :finished_at, DateTime.now
    end
  end

  def aggregated_entries
    ae = accounting_entries.select { |e| !e.manual? }.group_by { |e| e.from }.map do |from, entries|
      entries.group_by { |e| e.to }.map do |to, entries|
        AggregatedEntry.new(from, to, entries)
      end
    end
    ae.flatten + manual_accounting_entries
  end

  def concerned_financial_accounts
    accounting_entries.map { |e| [e.to, e.from] }.flatten.uniq
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

  def self.latest_finished_bank_debit_session_end
    AccountingSession.where(AccountingSession.arel_table[:finished_at].not_eq(nil)).where(:bank_debit => true).select(:end_date).maximum(:end_date) || (AbstractFlight.oldest_departure - 1.year).to_date
  end

private
  def remove_dates_if_without_flights
    self.without_flights = true if bank_debit?
    if without_flights?
      self.start_date = self.end_date = nil
    end
  end
end
