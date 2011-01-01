require File.dirname(__FILE__) + '/../../spec_helper'

describe "/wire_launch_cost_rules/index.html.haml" do
  before do
    assigns[:time_cost_rules] = @wire_launch_cost_rules = [WireLaunchCostRule.generate!, WireLaunchCostRule.generate!]
    assigns[:not_valid_anymore] = @not_valid_anymore = @wire_launch_cost_rules
    assigns[:valid] = @valid = @wire_launch_cost_rules
    assigns[:not_yet_valid] = @not_yet_valid = @wire_launch_cost_rules
  end

  it "should render" do
    render
  end
end
