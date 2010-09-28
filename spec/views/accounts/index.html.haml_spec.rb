require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/index.html.haml" do
  include AccountsHelper
  
  before do    
    assigns[:accounts] = @accounts = [Account.generate!, Account.generate!]
  end

  it "should render list of accounts" do
    render
  end
end
