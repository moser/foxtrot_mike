require 'spec_helper'

describe NumberCostRuleCondition do
  it "should only match a flight with the given condition" do
    f = Flight.spawn 
    f.duration = 30
    c = NumberCostRuleCondition.new :condition_field => "duration", :condition_operator => ">", :condition_value_i => 20
    c.matches?(f).should be_true
    f.duration = 19
    c.matches?(f).should be_false
  end
end
