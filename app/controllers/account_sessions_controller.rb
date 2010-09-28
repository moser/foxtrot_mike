class AccountSessionsController < ApplicationController
  def new
    @account_session = AccountSession.new
  end
  
  def create
    @account_session = AccountSession.new(params[:account_session])
    if @account_session.save
      redirect_to '/'
    else
      render :action => :new
    end
  end

  def destroy
    @account_session = AccountSession.find
    @account_session.destroy
    redirect_to '/login'
  end
end
