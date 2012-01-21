class OwnFinancialAccountsController < ApplicationController
  def show
    authorize! :read, :own_financial_account
    person = current_account.try(:person)
    @financial_account = person.try(:financial_account_at, Date.today)
    if @financial_account
      @accounting_entries = AccountingEntry.where(:from_id => @financial_account.id)
      if @financial_account.advance_payment?
        @accounting_entries += AdvancePayment.where(:financial_account_id => @financial_account.id)
        @saldo = AdvancePayment.where(:financial_account_id => @financial_account.id).sum(:value) -
                 AccountingEntry.where(:from_id => @financial_account.id).sum(:value)
      end
      @accounting_entries.sort_by { |e| e.date.to_date }
      render
    else
      redirect_to "/403.html"
    end
  end
end
