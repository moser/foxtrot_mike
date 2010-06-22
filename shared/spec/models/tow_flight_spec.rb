require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe TowFlight do
  it { should have_one :tow_launch }
  
  it "should not have a departure, from, cost_responsible of its own" do
    f = Factory.create(:flight, :launch => TowLaunch.create(:tow_flight => TowFlight.create))
    f.reload
    f.launch.tow_flight.departure.should == f.departure
    f.launch.tow_flight.departure = 1.week.ago
    f.launch.tow_flight.departure.should == f.departure
    f.launch.tow_flight.cost_responsible.should == f.cost_responsible
    f.launch.tow_flight.from.should == f.from
    f.launch.tow_flight.from = Airfield.generate!
    f.launch.tow_flight.from_id = Airfield.generate!.id
    f.launch.tow_flight.from.should == f.from
    f.launch.tow_flight.from_id.should == f.from_id
  end
end
