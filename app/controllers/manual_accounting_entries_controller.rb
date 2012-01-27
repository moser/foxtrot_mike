class ManualAccountingEntriesController < ApplicationController
  def index
    @accounting_session = AccountingSession.find(params[:accounting_session_id])
    authorize! :read, @accounting_session
    @accounting_entries = AccountingEntry.where(:manual => true, :accounting_session_id => @accounting_session.id)
  end

  def new
    @accounting_session = AccountingSession.find(params[:accounting_session_id])
    authorize! :update, @accounting_session
    if @accounting_session.finished?
      redirect_to [ @accounting_session, :manual_accounting_entries ]
    end
    @people = Person.where(:disabled => false)
  end

  def create
    @accounting_session = AccountingSession.find(params[:accounting_session_id])
    authorize! :update, @accounting_session
    if @accounting_session.finished?
      redirect_to [ @accounting_session, :manual_accounting_entries ]
    end
    @to = FinancialAccount.find(params[:to])
    params[:checked].keys.each do |person_id|
      person = Person.find(person_id)
      value = params[:value][person.id].to_i * 100
      unless value == 0
        AccountingEntry.create :from => person.financial_account_at(Date.today),
                               :to => @to,
                               :value => value,
                               :text => params[:text],
                               :manual => true,
                               :accounting_session => @accounting_session
      end
    end
    redirect_to [ @accounting_session, :manual_accounting_entries ]
  end
end
