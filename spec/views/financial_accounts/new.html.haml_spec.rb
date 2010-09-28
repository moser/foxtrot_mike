require 'spec_helper'

describe "financial_accounts/new.html.haml" do
  before(:each) do
    @financial_account = FinancialAccount.generate!
  end

  it "renders new financial_account form" do
    render
  end
end
