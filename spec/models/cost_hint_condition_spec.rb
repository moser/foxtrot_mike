require 'spec_helper'

describe CostHintCondition do
  it "should only match a flight which has the corresponding cost hint" do
    f = Flight.generate! :cost_hint => h = CostHint.generate!
    c = CostHintCondition.new :cost_hint => h
    c.matches?(f).should be_true
    f.cost_hint = CostHint.generate!
    c.matches?(f).should be_false
  end
end
