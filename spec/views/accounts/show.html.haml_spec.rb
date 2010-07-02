require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/show.html.haml" do
  include AccountsHelper
  
  before do
    @account = mock_model(Account)
    @account.stub!(:login).and_return("MyString")
    @account.stub!(:password).and_return()
    @account.stub!(:password_confirmation).and_return("MyString")

    assigns[:account] = @account
  end

  it "should render attributes in <p>" do
    render :template => "accounts/show.html.haml"
#    response.should have_text(/MyString/)
#    response.should have_text(//)
#    response.should have_text(/MyString/)
  end
end

