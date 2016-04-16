class BalanceSheetsController < ApplicationController
  Tpl = Struct.new :account, :balance
  def show
    authorize! :read, FinancialAccount
    @current_url = request.url
    @date = Date.today
    sort = params[:sort] || "name"
    raise "Unknown sort" unless %w{name balance}.include? sort
    @accounts = []
    if params[:report]
      @date = params[:report][:date]
      @accounts = FinancialAccount.all.map do |account|
        Tpl.new account, account.balance_at(@date)
      end.select do |obj|
        obj.balance != 0 and obj.account.number =~ /^[123]\d\d\d\d$/
      end.sort_by do |obj|
        obj.account.send(sort)
      end
    end
  end
end
