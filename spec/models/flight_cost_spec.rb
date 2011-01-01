require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FlightCost do
  it "should return nil/0 if there is no cost_responsible or plane" do
    f = Flight.new
    f.plane = Plane.generate! :can_fly_without_engine => true, :has_engine => true
    f.duration = 10
    f.engine_duration = 5
    f.save
    
  end

  it "should generate time costs for duration and engine_duration" do
    f = Flight.new
    f.cost.time_costs.find { |c| c.attribute == "duration" }.should_not be_nil
    f.cost.time_costs.find { |c| c.attribute == "engine_duration" }.should_not be_nil
  end
end
