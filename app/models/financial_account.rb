class FinancialAccount < ActiveRecord::Base
  has_many :financial_account_ownerships

  include Current
  has_many_current :financial_account_ownerships

  default_scope order("name asc")

  def owners
    current_financial_account_ownerships.map { |o| o.owner }
  end

  def to_s
    name
  end
end
