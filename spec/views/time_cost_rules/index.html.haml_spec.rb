require File.dirname(__FILE__) + '/../../spec_helper'

describe "/time_cost_rules/index.html.haml" do
  before do
    assigns[:time_cost_rules] = @time_cost_rules = [TimeCostRule.generate!, TimeCostRule.generate!]
    assigns[:not_valid_anymore] = @not_valid_anymore = @time_cost_rules
    assigns[:valid] = @valid = @time_cost_rules
    assigns[:not_yet_valid] = @not_yet_valid = @time_cost_rules
  end

  it "should render" do
    render
  end
end
