require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/new.html.haml" do
  include AccountsHelper
  
  before do
    @account = mock_model(Account)
    @account.stub!(:new_record?).and_return(true)
    @account.stub!(:login).and_return("MyString")
    @account.stub!(:password).and_return()
    @account.stub!(:password_confirmation).and_return("MyString")
    assigns[:account] = @account
  end

  it "should render new form" do
    render "/accounts/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", accounts_path) do
      with_tag("input#account_login[name=?]", "account[login]")
      with_tag("input#account_password[name=?]", "account[password]")
      with_tag("input#account_password_confirmation[name=?]", "account[password_confirmation]")
    end
  end
end
