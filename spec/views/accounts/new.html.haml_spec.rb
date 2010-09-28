require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/new.html.haml" do
  include AccountsHelper
  
  before do    
    assigns[:account] = @account = Account.spawn
  end

  it "should render new form" do
    render
  end
end
