require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TowFlight do
  it { should have_one :abstract_flight }
  
  it "should reset departure, from, cost_responsible when saved" do
    t = TowFlight.spawn :abstract_flight => f = Flight.generate!
    t.departure = 1.week.ago
    t.from = Airfield.generate!
    t.save
    t.departure.should == f.departure
    t.cost_responsible.should == f.cost_responsible
    t.from.should == f.from
  end
  
end
