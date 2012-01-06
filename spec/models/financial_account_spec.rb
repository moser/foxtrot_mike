require 'spec_helper'

describe FinancialAccount do
  it { should have_many :financial_account_ownerships }

  it "should return name on to_s" do
    f = FinancialAccount.generate!(:name => "lala", :number => 123)
    f.to_s.should == "lala (123)"
  end
end
