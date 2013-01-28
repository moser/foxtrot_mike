class FinancialAccount < ActiveRecord::Base
  has_many :financial_account_ownerships

  has_many :accounting_entries_from, :foreign_key => 'from_id', :class_name => 'AccountingEntry'
  has_many :accounting_entries_to, :foreign_key => 'to_id', :class_name => 'AccountingEntry'

  include Current
  has_many_current :financial_account_ownerships

  default_scope order("name asc")

  def owners
    financial_account_ownerships.map { |o| o.owner if o.valid_at(Time.now) }.compact.uniq
  end

  def to_s
    if number
      "#{name} (#{number})"
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
end
