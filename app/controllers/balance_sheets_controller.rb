class BalanceSheetsController < ApplicationController
  Tpl = Struct.new :account, :balance
  def show
    authorize! :read, FinancialAccount
    @date = Date.today
    @accounts = []
    if params[:report]
      @date = params[:report][:date]
      @accounts = FinancialAccount.all.map do |account|
        Tpl.new account, account.balance_at(@date)
      end.select do |obj|
        obj.balance != 0 and obj.account.number =~ /\d\d\d\d\d/
      end.sort_by do |obj|
        obj.account.name
      end
    end
  end
end
