class ExclusionsController < ApplicationController
  
  def create
    setup
    @accounting_session.add_excluded_account(@financial_account)
    redirect_to @accounting_session
  end

  def destroy
    setup
    @accounting_session.remove_excluded_account(@financial_account)
    redirect_to @accounting_session
  end

private
  def setup
    @accounting_session = AccountingSession.find(params[:accounting_session_id])
    authorize! :update, @accounting_session
    @financial_account = FinancialAccount.find(params[:id])
  end
end
