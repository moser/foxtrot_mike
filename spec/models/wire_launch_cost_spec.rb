require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WireLaunchCost do
  it "should return nil/0 if there is no cost_responsible or winch" do
    f = Flight.new
    f.launch = WireLaunch.create
    f.save
    f.cost.launch_cost.value.should == 0
  end
end
