require 'spec_helper'

describe WireLaunchCostItem do
  it "should create a free cost item" do
    l = WireLaunch.generate!
    i = WireLaunchCostItem.new :value => 10
    c = i.apply_to(l)
    c.value.should == 10
    c.free?.should be_true
    c.cost_item.should == i
  end

  it "should create a bound cost item" do
    l = WireLaunch.generate!
    i = WireLaunchCostItem.new :value => 10, :financial_account => FinancialAccount.generate!
    c = i.apply_to(l)
    c.value.should == 10
    c.free?.should be_false
    c.cost_item.should == i
  end
end
