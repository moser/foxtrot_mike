class FinancialAccountsController < ResourceController
  def model_all(conditions = nil, order = nil)
    unless order == 'balance'
      super(conditions, order)
    else
      @models = @financial_accounts = FinancialAccount.all.to_a.sort_by(&:balance)
    end
  end
end
