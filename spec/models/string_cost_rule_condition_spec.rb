require 'spec_helper'

describe StringCostRuleCondition do
  it "should only match a flight with the given condition" do
    f = Flight.generate! 
    c = StringCostRuleCondition.new :condition_field => "purpose", :condition_value_s => "training"
    c.matches?(f).should be_true
    f.stub(:purpose).and_return(:exercise)
    c.matches?(f).should be_false
  end
end
