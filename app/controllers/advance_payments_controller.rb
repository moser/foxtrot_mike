class AdvancePaymentsController < ApplicationController
  def show
    @advance_payment = AdvancePayment.find(params[:id])
    authorize! :read, @advance_payment
    respond_to do |f|
      f.pdf do
        render :pdf => "#{AdvancePayment.l}-#{@advance_payment.id}",
               :template => "advance_payments/show.html.haml",
               :disable_internal_links => true,
               :disable_external_links => true,
               :dpi => "90"
      end
    end
  end

  def new
    authorize! :create, AdvancePayment
    @financial_account = FinancialAccount.find(params[:financial_account_id])
    @advance_payment = AdvancePayment.new
  end

  def create
    authorize! :create, AdvancePayment
    @advance_payment = AdvancePayment.new params[:advance_payment]
    @financial_account = @advance_payment.financial_account = FinancialAccount.find(params[:financial_account_id])
    if @advance_payment.save
      redirect_to @financial_account
    else
      render :action => :new
    end
  end
end
