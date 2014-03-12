require 'csv'

class FinancialAccount < ActiveRecord::Base
  has_many :financial_account_ownerships

  has_many :accounting_entries_from, :foreign_key => 'from_id', :class_name => 'AccountingEntry'
  has_many :accounting_entries_to, :foreign_key => 'to_id', :class_name => 'AccountingEntry'

  belongs_to :first_debit_accounting_session, foreign_key: 'first_debit_accounting_session_id', class_name: 'AccountingSession'

  before_save :reset_first_debit_accounting_session

  include Current
  has_many_current :financial_account_ownerships

  default_scope order("number asc")

  def owners
    financial_account_ownerships.map { |o| o.owner if o.valid_at?(Time.now) }.compact.uniq
  end

  def to_s
    if number
      "#{number} (#{name})"
    else
      name
    end
  end

  def number?
    !number.nil? && number != ""
  end

  def balance
    AccountingEntry.where(to_id: id).select(:value).map(&:value).sum -
      AccountingEntry.where(from_id: id).select(:value).map(&:value).sum
  end

  def accounted_balance
    accounted = AccountingEntry.joins(:accounting_session).where('accounting_sessions.finished_at IS NOT NULL')
    accounted.where(to_id: id).select(:value).map(&:value).sum -
      accounted.where(from_id: id).select(:value).map(&:value).sum
  end

  def max_debit_value_f
    max_debit_value / 100.0
  end

  def max_debit_value_f=(f)
    f = f.to_f if String === f
    self.max_debit_value = (f.to_f * 100).to_i
  end

  def mandate_date_of_signature
    if mandate_id.blank? 
      nil
    else
      read_attribute(:mandate_date_of_signature)
    end
  end

  def kto_blz_to_iban
    if bank_code? && bank_account_number?
      cc = 'DE'
      ccd = '131400'
      bc = bank_code
      ac = '%010d' % bank_account_number.to_i
      bb = bc + ac
      cs = '%02d' % (98 - ((bb + ccd).to_i % 97))
      cc + cs + bb
    end
  end

  def blz_to_bic
    FuckingSepaBicLookup.lookup(bank_code) || []
  end

  def sequence_type(accounting_session)
    if first_debit_accounting_session.nil? || first_debit_accounting_session == accounting_session
      'FRST'
    else
      'RCUR'
    end
  end

  def self.to_csv(options = {})
    cols = [ :number, :name, :balance, :bank_account_holder, :bank_account_number, :bank_code, :member_account, :advance_payment, :max_debit_value ] 
    CSV.generate(options) do |csv|
      csv << cols
      all.each do |acc|
        csv << cols.map { |col| acc.send(col) }
      end
    end
  end

private
  def reset_first_debit_accounting_session
    if iban_changed? || bic_changed? || mandate_id_changed? || mandate_date_of_signature_changed?
      self.first_debit_accounting_session_id = nil
    end
  end
end
