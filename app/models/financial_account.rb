class FinancialAccount < ActiveRecord::Base
  has_many :financial_account_ownerships
  has_many :advance_payments
  has_many :advance_payments_from, :foreign_key => "from_id"

  include Current
  has_many_current :financial_account_ownerships

  default_scope order("name asc")

  def owners
    current_financial_account_ownerships.map { |o| o.owner }
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
end
