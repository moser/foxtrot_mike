class PasswordsController < ApplicationController
  def new
    @account = Account.find(params[:account_id]) if params[:account_id]
    @account ||= current_account
    @own = @account == current_account
    authorize! :update, @account unless @own
  end

  def create
    @account = Account.find(params[:account_id]) if params[:account_id]
    @account ||= current_account
    @own = @account == current_account
    authorize! :update, @account unless @own
    if @account.update_attributes(params[:account].reject { |k,v| ![:password, :password_confirmation].include?(k.to_sym) })
      flash[:success] = I18n.t("password_changed")
      if @own
        redirect_to "/"
      else
        redirect_to @account
      end
    else
      render :action => :new
    end
  end
end
