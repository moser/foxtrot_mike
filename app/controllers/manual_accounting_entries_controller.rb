class ManualAccountingEntriesController < ApplicationController
  class ImportException < Exception; end


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
    @a = FinancialAccount.find(params[:a])
    (params[:checked] || []).keys.each do |person_id|
      person = Person.find(person_id)
      value = params[:value][person.id].to_s.gsub(",",".").to_f * 100
      unless value == 0
        e = AccountingEntry.new :value => value,
                                :text => params[:text],
                                :manual => true,
                                :accounting_session => @accounting_session
        if params[:direction] == "debit"
          e.update_attributes :from => person.financial_account_at(Date.today),
                              :to => @a
        else
          e.update_attributes :to => person.financial_account_at(Date.today),
                              :from => @a
        end
        e.save
      end
    end
    redirect_to [ @accounting_session, :manual_accounting_entries ]
  end

  def import
    @accounting_session = AccountingSession.find(params[:accounting_session_id])
    authorize! :update, @accounting_session
    if file = params[:file]
      begin
        ActiveRecord::Base.transaction do
          @offending_rows = []
          CSV.foreach(file.path, headers: true) do |row|
            row = row.to_hash.merge(manual: true, accounting_session: @accounting_session)
            row['value_f'] = row['value_f'].gsub(',','.')
            accounting_entry = AccountingEntry.create(row)
            unless accounting_entry.valid?
              @offending_rows << [row, accounting_entry]
            end
          end
          raise ImportException.new unless @offending_rows.empty?
        end
      rescue ImportException
        render 'manual_accounting_entries/import_error', status: 422
      end
      if @offending_rows.empty?
        redirect_to [ @accounting_session, :manual_accounting_entries ], notice: "Import: OK"
      end
    else
      redirect_to [ @accounting_session, :manual_accounting_entries ]
    end
  end
end
