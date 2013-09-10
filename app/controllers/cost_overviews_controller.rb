class CostOverviewsController < ApplicationController
  def show
    @group = Group.find(params[:group_id])
    authorize! :read, @group
    @from = get_date(:from)
    @to = get_date(:to)
    @from ||= @group.flights.last.try(:departure_date) || Date.today
    @to ||= @group.flights.first.try(:departure_date) || Date.today
    @group_cost = GroupCost.new(@group, @from, @to)
  end

  def settle
    authorize! :create, AccountingSession
    @group = Group.find(params[:group_id])
    @account = FinancialAccount.find(params[:account_id])
    @from = get_date(:from)
    @to = get_date(:to)
    @group_cost = GroupCost.new(@group, @from, @to)
    unless @group && @account && @from && @to
      render action: :show
      return
    end
    redirect_to @group_cost.settle(params[:text], @account)
  end

private
  def get_date(key)
    begin
      Date.new(*params[:report].select { |k,v| k.include?(key.to_s) }.sort_by { |a| a.first }.map(&:last).map(&:to_i))
    rescue
    end
  end
end
