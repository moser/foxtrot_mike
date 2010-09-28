require 'spec_helper'

describe "financial_accounts/index.html.haml" do
  before(:each) do
    @financial_accounts = [FinancialAccount.generate!,  FinancialAccount.generate!]
  end

  it "renders a list of financial_accounts" do
    render
  end
end
