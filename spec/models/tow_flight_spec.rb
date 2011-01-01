require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TowFlight do
  it { should have_one :abstract_flight }
  
  it "should not have a departure, from, cost_responsible of its own" do
    TowFlight.generate! :abstract_flight => f = Flight.generate!
    f.reload
    f.launch.departure.should == f.departure
    f.launch.departure = 1.week.ago
    f.launch.departure.should == f.departure
    f.launch.cost_responsible.should == f.cost_responsible
    f.launch.from.should == f.from
    f.launch.from = Airfield.generate!
    f.launch.from_id = Airfield.generate!.id
    f.launch.from.should == f.from
    f.launch.from_id.should == f.from_id
  end
  
end
