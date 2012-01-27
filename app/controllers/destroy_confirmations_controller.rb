class DestroyConfirmationsController < ApplicationController
  def new
    @obj = parent
    authorize! :destroy, @obj
    redirect_to "/403.html" if AccountingEntry === @obj && !@obj.manual?
    render :layout => !request.xhr?
  end

  def create
    @obj = parent
    authorize! :destroy, @obj
    redirect_to "/403.html" if AccountingEntry === @obj && !@obj.manual?
    if @obj.destroy
      unless request.xhr?
        unless AccountingEntry === @obj
          redirect_to @obj.class
        else
          redirect_to accounting_session_manual_accounting_entries_path(@obj.accounting_session)
        end
      else
        head :ok
      end
    else
      redirect_to "/403.html"
    end
  end

private
  def parent
    [ :flight, :accounting_entry ].each do |o|
      return o.to_s.camelcase.constantize.find(params["#{o}_id"]) if params["#{o}_id"]
    end
  end
end
