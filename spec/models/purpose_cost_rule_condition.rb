require 'spec_helper'

describe PurposeCostRuleCondition do
  it "should only match a flight which has the corresponding purpose" do
    f = Flight.generate!
    c = PurposeCostRuleCondition.new purpose_filter: 'training'
    p f.purpose
    c.matches?(f).should be_true
  end
end
