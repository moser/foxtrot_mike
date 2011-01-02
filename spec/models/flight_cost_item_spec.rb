require 'spec_helper'

describe FlightCostItem do
  it "should create a free cost item" do
    f = Flight.generate!
    f.duration = 10
    i = FlightCostItem.new :value => 10, :depends_on => "duration"
    c = i.apply_to(f)
    c.value.should == 100
    c.free?.should be_true
    c.cost_item.should == i
  end

  it "should create a bound cost item" do
    f = Flight.generate!
    f.duration = 10
    i = FlightCostItem.new :value => 10, :depends_on => "duration", :financial_account => FinancialAccount.generate!
    c = i.apply_to(f)
    c.value.should == 100
    c.free?.should be_false
    c.financial_account.should == i.financial_account
    c.cost_item.should == i
  end

  it "should ignore nils on depends_on, value and additive_value" do
    f = Flight.generate!
    f.duration = 10
    i = FlightCostItem.new
    i.apply_to(f).value.should == 0
    i.depends_on = "duration"
    i.apply_to(f).value.should == 0
    i.additive_value = 10
    i.apply_to(f).value.should == 10
    i.value = 10
    i.apply_to(f).value.should == 110
  end

  it "should not generate a negative value" do
    f = Flight.generate!
    f.duration = 10
    i = FlightCostItem.new :additive_value => -10
    i.apply_to(f).value.should == 0
  end
end
