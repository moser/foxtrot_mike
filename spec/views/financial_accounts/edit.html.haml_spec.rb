require 'spec_helper'

describe "financial_accounts/edit.html.haml" do
  before(:each) do
    @financial_account = FinancialAccount.generate!
  end

  it "renders the edit financial_account form" do
    render
  end
end
