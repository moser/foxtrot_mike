require 'csv'

class FinancialAccount < ActiveRecord::Base
  has_many :financial_account_ownerships

  has_many :accounting_entries_from, :foreign_key => 'from_id', :class_name => 'AccountingEntry'
  has_many :accounting_entries_to, :foreign_key => 'to_id', :class_name => 'AccountingEntry'

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

  def max_debit_value_f
    max_debit_value / 100.0
  end

  def max_debit_value_f=(f)
    f = f.to_f if String === f
    self.max_debit_value = (f.to_f * 100).to_i
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
end
