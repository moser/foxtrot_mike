require 'spec_helper'

describe "financial_accounts/show.html.haml" do
  before(:each) do
   @financial_account = FinancialAccount.generate!
  end

  it "renders attributes in <p>" do
    render
  end
end
