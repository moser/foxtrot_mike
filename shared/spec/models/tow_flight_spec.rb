require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe TowFlight do
  it { should have_one :tow_launch }
  
  it "should not have a departure of its own" do
    f = Factory.create(:flight, :launch => TowLaunch.create(:tow_flight => TowFlight.create))
    f.reload
    f.launch.tow_flight.departure.should == f.departure
    f.launch.tow_flight.departure = 1.week.ago
    f.launch.tow_flight.departure.should == f.departure
  end
end
