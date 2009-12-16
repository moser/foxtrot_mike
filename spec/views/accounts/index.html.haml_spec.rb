require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/index.html.haml" do
  include AccountsHelper
  
  before do
    account_98 = mock_model(Account)
    account_98.should_receive(:login).and_return("MyString")
    account_98.should_receive(:password).and_return()
    account_98.should_receive(:password_confirmation).and_return("MyString")
    account_99 = mock_model(Account)
    account_99.should_receive(:login).and_return("MyString")
    account_99.should_receive(:password).and_return()
    account_99.should_receive(:password_confirmation).and_return("MyString")

    assigns[:accounts] = [account_98, account_99]
  end

  it "should render list of accounts" do
    render "/accounts/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
  end
end
