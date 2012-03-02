class OwnFinancialAccountsController < ApplicationController
  def show
    authorize! :read, :own_financial_account
    person = current_account.try(:person)
    @financial_account = person.try(:financial_account_at, Date.today)
    if @financial_account
      @accounting_entries = AccountingEntry.where("from_id = ? OR to_id = ?", @financial_account.id, @financial_account.id).sort_by { |e| e.date }
      if @financial_account.advance_payment?
        @saldo = @accounting_entries.find_all { |a| a.to_id == @financial_account.id }.map(&:value).sum -
                 @accounting_entries.find_all { |a| a.from_id == @financial_account.id }.map(&:value).sum
      end
      render
    else
      redirect_to "/403.html"
    end
  end
end
