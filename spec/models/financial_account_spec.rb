require 'spec_helper'

describe FinancialAccount do
  it "should return name on to_s" do
    f = FinancialAccount.generate!(:name => "lala")
    f.to_s.should == "lala"
  end
end
