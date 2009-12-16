require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsHelper do
  it "link_to_current_account should create a link" do
    mock_account = mock_model Account
    mock_account.should_receive(:login).and_return("str")
    helper.should_receive(:current_account).twice.and_return(mock_account)
    helper.link_to_current_account.should =~ /<a href=\"\/accounts\/(.*)\">str<\/a>/
  end
end
