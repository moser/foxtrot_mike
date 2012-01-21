require 'spec_helper'

describe AdvancePayment do
  it { should belong_to :financial_account }

  describe "#value_f" do
    it "should divide the given value by 100" do
      a = AdvancePayment.new :value => 2222
      a.value_f.should == 22.22
    end

    it "should multiply the parameter by 100" do
      a = AdvancePayment.new
      a.value_f = 1.01
      a.value.should == 101
      a.value_f = 1.001
      a.value.should == 100
      a.value_f = "1.01"
      a.value.should == 101
    end
  end
end
