require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe WireLaunchCost do
  it "should return nil/0 if there is no cost_responsible or winch" do
    f = Flight.new
    f.launch = WireLaunch.create
    f.save
    f.cost.to_i.should == 0
    f.cost.cost_rule.should be_nil
  end
end
