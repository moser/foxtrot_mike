class OwnFinancialAccountsController < ApplicationController
  def show
    authorize! :read, :own_financial_account
    person = current_account.try(:person)
    financial_account = person.try(:financial_account)
    p financial_account
    if financial_account
      @accounting_entries = AccountingEntry.where(:from_id => financial_account.id).order("created_at DESC").limit(50)
      render
    else
      redirect_to "/403.html"
    end
  end
end
