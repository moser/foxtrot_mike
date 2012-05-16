class FinancialAccountOverviewsController < ApplicationController
  def show
    authorize! :read, :own_financial_account
    unless params[:financial_account_id]
      person = current_account.try(:person)
      @financial_account = person.try(:financial_account_at, Date.today)
    else
      @financial_account = FinancialAccount.find(params[:financial_account_id])
    end
    if @financial_account
      render
    else
      redirect_to "/403.html"
    end
  end
end
