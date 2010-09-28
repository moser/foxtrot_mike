require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/edit.html.haml" do
  include AccountsHelper
  
  before do    
    assigns[:account] = @account = Account.generate!
  end

  it "should render edit form" do
    render
  end
end
