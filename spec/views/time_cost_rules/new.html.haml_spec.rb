require File.dirname(__FILE__) + '/../../spec_helper'

describe "/time_cost_rules/new.html.haml" do
  include TimeCostRulesHelper
  
  before do
    assigns[:time_cost_rule] = @time_cost_rule = TimeCostRule.spawn
  end

  it "should render" do
    render
  end
end
