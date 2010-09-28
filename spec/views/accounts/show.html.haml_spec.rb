require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/show.html.haml" do
  include AccountsHelper
  
  before do
    assigns[:account] = @account = Account.generate!
  end

  it "should render" do
    render
  end
end

