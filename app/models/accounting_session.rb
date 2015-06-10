class AccountingSession < ActiveRecord::Base
  has_many :accounting_entries
  has_many :flights, :order => "departure_date ASC, departure_date ASC"
  has_many :first_debit_financial_accounts, class_name: 'FinancialAccount', foreign_key: 'first_debit_accounting_session_id'

  belongs_to :credit_financial_account, :class_name => "FinancialAccount"

  serialize :exclusions, Array

  validates_presence_of :name, :voucher_number, :accounting_date
  validates_presence_of :start_date, :end_date, :if => lambda { |s| !s.without_flights? }
  validates_presence_of :credit_financial_account, :if => lambda { |s| s.bank_debit? }
  validate do |a|
    errors.add(:end_date, AccountingSession.l(:must_not_be_in_the_future)) if !(a.without_flights? || a.bank_debit?) && a.end_date && a.end_date > DateTime.now.to_date
  end

  before_save :remove_dates_if_without_flights
  before_destroy :destroy_manual_accounting_entries

  default_scope order('accounting_date DESC')

  attr_reader :problems
  def soft_validate
    @problems = {}
    unless without_flights?
      unaccounted_flights = Flight.where(Flight.arel_table[:departure_date].lt(start_date)).where(:accounting_session_id => nil)
      count = unaccounted_flights.count
      oldest = unaccounted_flights.pluck(:departure_date).min
      if count > 0
        @problems[:unaccounted_flights_before_start] = { :count => count, :oldest => I18n.l(oldest), :ids => unaccounted_flights.limit(10).pluck(:id).join(" ") }
      end
    end
    @problems[:financial_account_missing_number] = {} if concerned_financial_accounts.find { |a| !a.number? }
    @problems.empty?
  end

  def exclusions
    read_attribute(:exclusions) || []
  end

  def add_excluded_account(financial_account)
    self.exclusions << financial_account
    self.save
  end

  def remove_excluded_account(financial_account)
    self.exclusions.delete(financial_account)
    self.save
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
        flights.map { |f| f.calculate_cost_if_necessary; f.accounting_entries }.flatten + manual_accounting_entries
      else
        negative_financial_accounts.select do |financial_account|
          !self.exclusions.include?(financial_account)
        end.map do |financial_account|
          AccountingEntry.new(:from => credit_financial_account, 
                              :to => financial_account, 
                              :value => [-financial_account.accounted_balance, financial_account.max_debit_value].min, 
                              :accounting_session => self, 
                              :text => name)
        end
      end
    end
  end
  alias_method_chain :accounting_entries, :default

  def negative_financial_accounts 
    if debit_type == 'dta'
      FinancialAccount.where("bank_account_number != ''").where(:advance_payment => false, :member_account => true).select { |f| f.accounted_balance < 0 }
    else
      FinancialAccount.where("iban != ''").where(:advance_payment => false, :member_account => true).select { |f| f.accounted_balance < 0 }
    end
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

  def dta?
    debit_type == 'dta'
  end

  def sepa?
    debit_type == 'sepa'
  end

  def any_first?
    !first_debit_financial_accounts.empty?
  end

  def any_recurring?
    accounting_entries.any? { |ae| ae.to.first_debit_accounting_session != self }
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
        accounting_entries.each do |e|
          if self.sepa? && e.to.first_debit_accounting_session.nil?
            e.to.update_attribute :first_debit_accounting_session_id, self.id
          end
          e.save
        end
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


  def bookings_csv
    (RUBY_VERSION =~ /^1\.9/ ? CSV : FasterCSV).generate do |csv|
      csv << %w(booking_date voucher_number from_account_number to_account_number value_f text)
      
      aggregated_entries.each do |entry|
        csv << [ accounting_date.to_s, voucher_number, %w(from_account_number to_account_number value_f).map { |f| entry.send(f) }, 
                 "#{ name } #{ entry.manual? ? entry.text : "" }" ].flatten
      end
    end
  end


  def filename
    "#{ finished_at.to_date }-#{ AccountingSession.l(:entries) }-#{ voucher_number }-#{ name.gsub(" ", "-") }.txt"
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

  def destroy_manual_accounting_entries
    self.manual_accounting_entries.destroy_all
  end
end
