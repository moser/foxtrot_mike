require File.dirname(__FILE__) + '/../../spec_helper'

describe "/account/edit.html.haml" do
  include AccountsHelper
  
  before do
    @account = mock_model(Account)
    @account.stub!(:login).and_return("MyString")
    @account.stub!(:password).and_return()
    @account.stub!(:password_confirmation).and_return("MyString")
    assigns[:account] = @account
  end

  it "should render edit form" do
    render "/accounts/edit.html.haml"
    
    response.should have_tag("form[action=#{account_path(@account)}][method=post]") do
      with_tag('input#account_login[name=?]', "account[login]")
      with_tag('input#account_password[name=?]', "account[password]")
      with_tag('input#account_password_confirmation[name=?]', "account[password_confirmation]")
    end
  end
end
