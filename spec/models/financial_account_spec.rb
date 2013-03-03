require 'spec_helper'

describe FinancialAccount do
  it { should have_many :financial_account_ownerships }

  it "should return name on to_s" do
    f = FinancialAccount.generate!(:name => "lala", :number => 123)
    f.to_s.should == "123 (lala)"
  end

  describe "#max_debit_value_f" do
    it "set the real value" do
      f = FinancialAccount.generate!
      f.max_debit_value_f = 100
      f.max_debit_value.should == 10000
    end

    it "returns a float value" do
      f = FinancialAccount.generate!
      f.max_debit_value = 101
      f.max_debit_value_f.should == 1.01
    end
  end
end
